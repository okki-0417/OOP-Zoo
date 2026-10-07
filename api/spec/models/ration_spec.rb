# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ration do
  subject(:ration) { described_class.new(animal:, foods:) }

  let(:animal) { build(:animal).get_hungrier(hunger) }
  let(:hunger) { 0 }
  let(:foods) { FoodCatalog.all }

  describe '#foods' do
    context '満腹のライオンのとき' do
      it '肉で最も満腹度の高い馬肉を1つだけ返すこと' do
        expect(ration.foods).to eq([FoodCatalog.horse_meat])
      end
    end

    context '空腹度60のライオンのとき' do
      let(:hunger) { 60 }

      it '満腹度35の馬肉を2つ(計70)返すこと' do
        expect(ration.foods).to eq([FoodCatalog.horse_meat] * 2)
      end

      context '品揃えが干し草とバナナだけのとき' do
        let(:foods) { [FoodCatalog.hay, FoodCatalog.banana] }

        it '食性に合う餌がないので空配列を返すこと' do
          expect(ration.foods).to eq([])
        end
      end
    end

    context '満たしきれないほど空腹(空腹度100)のアフリカゾウのとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.african_elephant).get_hungrier(100) }

      it 'MAX_SERVINGS(6)個を返すこと' do
        expect(ration.foods.size).to eq(described_class::MAX_SERVINGS)
      end
    end
  end
end
