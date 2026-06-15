# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Operations
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
            Husbandry::Enclosure.new(name: 'A', temperature: Shared::Temperature.celsius(20), capacity: 4)
          end
          zebras = Array.new(5) { Taxonomy::SpeciesCatalog.grevys_zebra }
          food = zebras.sum(0) { |s| Husbandry::Metabolism.daily_food_cost(s).yen }

          cost = described_class.daily(enclosures: enclosures, staff: 3, species: zebras)

          expect(cost).to eq(Shared::Money.yen((2 * 1000) + (3 * 3000) + food))
        end

        it '空調付きエリアは稼働費が上乗せされること' do
          plain = Husbandry::Enclosure.new(name: '平', temperature: Shared::Temperature.celsius(20), capacity: 4)
          controlled = Husbandry::Enclosure.new(
            name: '空調', temperature: Shared::Temperature.celsius(20), capacity: 4, climate_controlled: true
          )

          plain_cost = described_class.daily(enclosures: [plain], staff: 0, species: [])
          controlled_cost = described_class.daily(enclosures: [controlled], staff: 0, species: [])

          expect(controlled_cost).to be > plain_cost
        end
      end

      RSpec.describe VisitorAttraction do
        catalog = Taxonomy::SpeciesCatalog

        fee = Shared::Money.yen(2_000) # 基準料金

        it '展示が空なら来園者は0であること' do
          expect(described_class.expected_visitors([], Reputation.default, fee)).to eq(0)
        end

        def zebra
          Animal.new(
            species: Taxonomy::SpeciesCatalog.grevys_zebra, name: 'シマオ', sex: Animal::Sex.male, max_health: 100
          )
        end

        it '線形需要: 評判100・料金¥2,000・魅力80(シマウマ60+多様性20)で41人を期待すること' do
          # Qmax=80, Pmax=3000+80*15=4200, 来園=floor(80*(1-2000/4200))=41
          expect(described_class.expected_visitors([zebra], Reputation.new(100), fee)).to eq(41)
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

      RSpec.describe OutbreakPolicy do
        def animal(name = 'シマオ')
          Animal.new(
            species: Taxonomy::SpeciesCatalog.grevys_zebra, name: name, sex: Animal::Sex.male, max_health: 100
          )
        end

        it '発生する乱数(rand<20)では健康な個体を1頭返すこと' do
          random = instance_double(Random)
          allow(random).to receive(:rand).and_return(0)
          target = animal

          expect(described_class.strike([target], random)).to eq(target)
        end

        it '発生しない乱数(rand>=20)では nil を返すこと' do
          random = instance_double(Random, rand: 50)

          expect(described_class.strike([animal], random)).to be_nil
        end

        it '健康な個体がいなければ nil を返すこと' do
          sick = animal.fall_ill(Medical::IllnessCatalog.parasite)
          random = instance_double(Random, rand: 0)

          expect(described_class.strike([sick], random)).to be_nil
        end
      end

      RSpec.describe ReputationPolicy do
        it '死亡が2件あると評判を 5*2=10 下げること' do
          expect(described_class.after_day(Reputation.new(50), deaths: 2).score).to eq(40)
        end

        it '死亡が無い日は評判を2上げること' do
          expect(described_class.after_day(Reputation.new(50), deaths: 0).score).to eq(52)
        end
      end
    end
  end
end
