# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Reputation do
  describe '#gain' do
    it '評判95に10を足しても上限の100で止まること' do
      expect(described_class.new(95).gain(10).score).to eq(100)
    end
  end

  describe '#lose' do
    it '評判3から10を引いても下限の0で止まること' do
      expect(described_class.new(3).lose(10).score).to eq(0)
    end
  end

  describe '#after_day' do
    subject(:after) { described_class.new(value).after_day(experience:, exposure:, events:) }

    let(:value) { 50 }
    let(:experience) { 100 }
    let(:exposure) { Zoo::Reputation::EXPOSURE_REFERENCE }
    let(:events) { [] }

    context '評判0・体験100で露出が満杯のとき' do
      let(:value) { 0 }

      it '上げ幅が DRIFT_CAP でクランプされ score が3になること' do
        expect(after.score).to eq(3)
      end
    end

    context '評判50・体験0で露出が満杯のとき' do
      let(:experience) { 0 }

      it '下げは上げの倍速で -6 され score が44になること' do
        expect(after.score).to eq(44)
      end
    end

    context '評判50・体験100で露出が来場5のとき' do
      let(:exposure) { 5 }

      it 'score が50のまま動かないこと' do
        expect(after.score).to eq(50)
      end
    end

    context '評判50・体験96で露出が来場10のとき' do
      let(:experience) { 96 }
      let(:exposure) { 10 }

      it '1日では score が50のままであること' do
        expect(after.score).to eq(50)
      end

      it '60日続けると端数が累積して score が50を超えること' do
        many = described_class.new(value)
        60.times { many = many.after_day(experience:, exposure:) }

        expect(many.score).to be > 50
      end
    end

    context '露出ゼロ' do
      let(:exposure) { 0 }

      context '評判が中立を超える70のとき' do
        let(:value) { 70 }

        it '中立へ DECAY_RATE 分だけ減衰した値になること' do
          expected = 70 - (Zoo::Reputation::DECAY_RATE * (70 - Zoo::Reputation::DECAY_ANCHOR))

          expect(after.value).to be_within(1e-9).of(expected)
        end
      end

      context '評判が中立以下の40で体験0のとき' do
        let(:value) { 40 }
        let(:experience) { 0 }

        it '減衰せず value が40のままであること' do
          expect(after.value).to eq(40)
        end
      end

      context '評判50に死亡(charisma 50)のニュースが2件あるとき' do
        let(:events) { Array.new(2) { ReputationEvent::Death.new(cause: :unknown, charisma: 50) } }

        it 'reputation_delta の和だけ下がり score が40になること' do
          expect(after.score).to eq(40)
        end
      end
    end

    context '評判50・体験50・露出100で疫病(Outbreak)のニュースがあるとき' do
      let(:experience) { 50 }
      let(:exposure) { 100 }
      let(:events) { [ReputationEvent::Outbreak.new] }

      it 'PENALTY(8)だけ下がり score が42になること' do
        expect(after.score).to eq(42)
      end
    end

    context '評判0・体験0・露出100で死亡のニュースが5件あるとき' do
      let(:value) { 0 }
      let(:experience) { 0 }
      let(:exposure) { 100 }
      let(:events) { Array.new(5) { ReputationEvent::Death.new(cause: :unknown, charisma: 50) } }

      it '負にならず score が0でクランプされること' do
        expect(after.score).to eq(0)
      end
    end
  end
end

RSpec.describe OperatingCost do
  describe '#amount' do
    subject(:amount) { described_class.new(enclosures:, staff:, species:).amount }

    let(:enclosures) { build_list(:enclosure, 2, celsius: 20) }
    let(:staff) { build_list(:keeper, 3) }
    let(:species) { Array.new(5) { SpeciesCatalog.grevys_zebra } }

    it 'エリア2つの維持費・飼育員3人の給与・グレビーシマウマ5頭の飼料費の合計を返すこと' do
      upkeep = 2 * Enclosure::UPKEEP_YEN
      salaries = 3 * Keeper::DAILY_SALARY_YEN
      food = 5 * SpeciesCatalog.grevys_zebra.daily_food_cost.yen

      expect(amount).to eq(Money.yen(upkeep + salaries + food))
    end

    context '空調付きのエリアが1つだけのとき' do
      let(:enclosures) { [build(:enclosure, celsius: 20, climate_controlled: true)] }
      let(:staff) { [] }
      let(:species) { [] }

      it '空調なしのエリア1つより高くなること' do
        plain = described_class.new(enclosures: [build(:enclosure, celsius: 20)], staff: [], species: []).amount

        expect(amount).to be > plain
      end
    end
  end
end

RSpec.describe VisitorAttraction do
  describe '#expected_visitors' do
    subject(:visitors) { described_class.new(on_exhibit:, zoo:).expected_visitors }

    let(:zoo) { instance_double(Zoo, reputation_factor: Zoo::Reputation.new(reputation).factor, admission_fee:, buzz: 0) }
    let(:reputation) { 100 }
    let(:admission_fee) { Money.yen(2_000) }
    let(:on_exhibit) { [build(:animal, :newborn, species: SpeciesCatalog.grevys_zebra)] }

    context '展示が空のとき' do
      let(:on_exhibit) { [] }
      let(:reputation) { Zoo::Reputation.default.score }

      it '0を返すこと' do
        expect(visitors).to eq(0)
      end
    end

    context '評判100・料金¥2,000でシマウマ1頭を展示しているとき' do
      it '線形需要で28を返すこと' do
        expect(visitors).to eq(28)
      end
    end

    context '評判が50のとき' do
      let(:reputation) { 50 }

      it '評判100での28人より少ないこと' do
        expect(visitors).to be < 28
      end
    end

    context '料金が¥4,000のとき' do
      let(:admission_fee) { Money.yen(4_000) }

      it '料金¥2,000での28人より少ないこと' do
        expect(visitors).to be < 28
      end
    end

    context '料金が支払意思を超える¥100,000のとき' do
      let(:admission_fee) { Money.yen(100_000) }

      it '0を返すこと' do
        expect(visitors).to eq(0)
      end
    end
  end
end

RSpec.describe SpontaneousInfection do
  describe '#strike' do
    subject(:strike) { described_class.new(animals, random).strike }

    let(:animal) { build(:animal, :newborn, species: SpeciesCatalog.grevys_zebra) }
    let(:animals) { [animal] }
    let(:random) { instance_double(Random, rand: 0) }

    context '発生する乱数(rand=0 < 20)のとき' do
      it '対象個体を発病させて返すこと' do
        expect(strike).to eq(animal)
        expect(animal).to be_sick
      end
    end

    context '発生しない乱数(rand=50 >= 20)のとき' do
      let(:random) { instance_double(Random, rand: 50) }

      it 'nil を返すこと' do
        expect(strike).to be_nil
      end
    end

    context '健康な個体がいないとき' do
      let(:animal) { build(:animal, :newborn, species: SpeciesCatalog.grevys_zebra).fall_ill(IllnessCatalog.parasite) }

      it 'nil を返すこと' do
        expect(strike).to be_nil
      end
    end
  end
end
