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
        it 'エリア2・職員3・個体5で 2*1000+3*3000+5*500=¥13,500 を返すこと' do
          cost = described_class.daily(enclosures: 2, animals: 5, staff: 3)

          expect(cost).to eq(Shared::Money.yen(13_500))
        end
      end

      RSpec.describe VisitorAttraction do
        catalog = Taxonomy::SpeciesCatalog

        it '展示が空なら来園者は0であること' do
          expect(described_class.expected_visitors([], Reputation.default)).to eq(0)
        end

        it '評判100で 多様性1種(×20)＋希少種1(×30)=50人 を期待すること(EN のシマウマ)' do
          animal = Animal.new(
            species: catalog.grevys_zebra, name: 'シマオ', sex: Animal::Sex.male, max_health: 100
          )

          expect(described_class.expected_visitors([animal], Reputation.new(100))).to eq(50)
        end

        it '評判50では期待来園者が半減すること(50→25人)' do
          animal = Animal.new(
            species: catalog.grevys_zebra, name: 'シマオ', sex: Animal::Sex.male, max_health: 100
          )

          expect(described_class.expected_visitors([animal], Reputation.new(50))).to eq(25)
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
