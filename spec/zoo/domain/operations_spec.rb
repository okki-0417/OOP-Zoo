# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Reputation do
      it 'gain は上限100を超えないこと' do
        expect(Reputation.new(95).gain(10).score).to eq(100)
      end

      it 'lose は下限0を下回らないこと' do
        expect(Reputation.new(3).lose(10).score).to eq(0)
      end
    end

    RSpec.describe OperatingCost do
      it 'エリア維持費・職員給与・在園個体の飼料費(種ごと)の合計を返すこと' do
        enclosures = Array.new(2) do
          Enclosure.new(name: 'A', temperature: Shared::Temperature.celsius(20), capacity: 4)
        end
        zebras = Array.new(5) { SpeciesCatalog.grevys_zebra }
        food = zebras.sum { |s| s.daily_food_cost.yen }

        cost = described_class.daily(enclosures: enclosures, staff: 3, species: zebras)

        upkeep = 2 * described_class::UPKEEP_PER_ENCLOSURE
        salaries = 3 * described_class::SALARY_PER_STAFF
        expect(cost).to eq(Shared::Money.yen(upkeep + salaries + food))
      end

      it '空調付きエリアは稼働費が上乗せされること' do
        plain = Enclosure.new(name: '平', temperature: Shared::Temperature.celsius(20), capacity: 4)
        controlled = Enclosure.new(
          name: '空調', temperature: Shared::Temperature.celsius(20), capacity: 4, climate_controlled: true
        )

        plain_cost = described_class.daily(enclosures: [plain], staff: 0, species: [])
        controlled_cost = described_class.daily(enclosures: [controlled], staff: 0, species: [])

        expect(controlled_cost).to be > plain_cost
      end
    end

    RSpec.describe VisitorAttraction do
      fee = Shared::Money.yen(2_000)

      it '展示が空なら来園者は0であること' do
        expect(described_class.expected_visitors([], Reputation.default, fee)).to eq(0)
      end

      def zebra
        Animal.new(
          species: SpeciesCatalog.grevys_zebra, name: 'シマオ', sex: Animal::Sex.male, max_health: 100
        )
      end

      it '線形需要: 評判100・料金¥2,000・見応え≈59(シマウマ60を飽和)で28人を期待すること' do
        expect(described_class.expected_visitors([zebra], Reputation.new(100), fee)).to eq(28)
      end

      it '評判が下がると来園が減ること(100→50)' do
        high = described_class.expected_visitors([zebra], Reputation.new(100), fee)
        low  = described_class.expected_visitors([zebra], Reputation.new(50), fee)
        expect(low).to be < high
      end

      it '料金を上げると来園が減ること(単位弾力ではなく、収益には最適点がある)' do
        cheap  = described_class.expected_visitors([zebra], Reputation.new(100), Shared::Money.yen(2_000))
        pricey = described_class.expected_visitors([zebra], Reputation.new(100), Shared::Money.yen(4_000))
        expect(pricey).to be < cheap
      end

      it '支払意思(Pmax)以上の料金では来園が0になること(choke price)' do
        expect(described_class.expected_visitors([zebra], Reputation.new(100), Shared::Money.yen(100_000))).to eq(0)
      end
    end

    RSpec.describe SpontaneousInfection do
      def animal(name = 'シマオ')
        Animal.new(
          species: SpeciesCatalog.grevys_zebra, name: name, sex: Animal::Sex.male, max_health: 100
        )
      end

      it '発生する乱数(rand<20)では対象個体を発病させて返すこと' do
        random = instance_double(Random)
        allow(random).to receive(:rand).and_return(0)
        target = animal

        result = described_class.apply([target], random)

        expect(result).to eq(target)
        expect(target).to be_sick
      end

      it '発生しない乱数(rand>=20)では nil を返すこと' do
        random = instance_double(Random, rand: 50)

        expect(described_class.apply([animal], random)).to be_nil
      end

      it '健康な個体がいなければ nil を返すこと' do
        sick = animal.fall_ill(IllnessCatalog.parasite)
        random = instance_double(Random, rand: 0)

        expect(described_class.apply([sick], random)).to be_nil
      end
    end

    RSpec.describe Reputation do
      it '体験経路: 露出満杯・体験100・評判0なら、上げ幅は DRIFT_CAP(3)でクランプされること' do
        expect(Reputation.new(0).after_day(experience: 100,
                                           exposure: Reputation::EXPOSURE_REFERENCE).score).to eq(3)
      end

      it '非対称: 下げは上げの倍速(体験0・評判50・露出満杯で -6 の 44)であること' do
        expect(Reputation.new(50).after_day(experience: 0,
                                            exposure: Reputation::EXPOSURE_REFERENCE).score).to eq(44)
      end

      it '露出が小さい(来場5)と、同じ体験でも評判はほとんど動かないこと' do
        expect(Reputation.new(50).after_day(experience: 100, exposure: 5).score).to eq(50)
      end

      it '露出が小さく1日では1点未満の前進でも、続ければ端数が累積して評判が動くこと' do
        one = Reputation.new(50).after_day(experience: 96, exposure: 10)
        expect(one.score).to eq(50)

        many = Reputation.new(50)
        60.times { many = many.after_day(experience: 96, exposure: 10) }
        expect(many.score).to be > 50
      end

      it '中立超えの評判は、露出ゼロでも中立へ DECAY_RATE 分だけ減衰すること' do
        after = Reputation.new(70).after_day(experience: 100, exposure: 0)
        expected = 70 - (Reputation::DECAY_RATE * (70 - Reputation::DECAY_ANCHOR))
        expect(after.value).to be_within(1e-9).of(expected)
      end

      it '中立以下の評判は自然減衰しないこと' do
        after = Reputation.new(40).after_day(experience: 0, exposure: 0)
        expect(after.value).to eq(40)
      end

      it '来場ゼロでもニュース経路(死亡)は効き、events の reputation_delta の和だけ下げること' do
        deaths = Array.new(2) { ReputationEvent::Death.new(cause: :unknown, charisma: 50) }
        expect(Reputation.new(50).after_day(experience: 100, exposure: 0,
                                            events: deaths).score).to eq(40)
      end

      it '疫病(Outbreak)が出ると PENALTY(8)だけ下げること' do
        events = [ReputationEvent::Outbreak.new]
        expect(Reputation.new(50).after_day(experience: 50, exposure: 100,
                                            events: events).score).to eq(42)
      end

      it '評判は 0..100 にクランプされること(過大なイベントでも負にならない)' do
        deaths = Array.new(5) { ReputationEvent::Death.new(cause: :unknown, charisma: 50) }
        expect(Reputation.new(0).after_day(experience: 0, exposure: 100,
                                           events: deaths).score).to eq(0)
      end
    end
  end
end
