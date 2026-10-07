# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ration do
  describe '#foods' do
    it '満腹のライオンには、肉で最も満腹度の高い馬肉を1つだけ返すこと' do
      ration = described_class.new(animal: build(:animal), foods: FoodCatalog.all)
      expect(ration.foods).to eq([FoodCatalog.horse_meat])
    end

    it '空腹度60のライオンには、満腹度35の馬肉を2つ(計70)返すこと' do
      lion = build(:animal).get_hungrier(60)
      expect(described_class.new(animal: lion, foods: FoodCatalog.all).foods).to eq([FoodCatalog.horse_meat] * 2)
    end

    it '満たしきれないほど空腹でも MAX_SERVINGS(6)を超えないこと' do
      elephant = build(:animal, species: SpeciesCatalog.african_elephant).get_hungrier(100)
      expect(described_class.new(animal: elephant, foods: FoodCatalog.all).foods.size).to eq(described_class::MAX_SERVINGS)
    end

    it '食性に合う餌が品揃えに1つもなければ空配列を返すこと' do
      lion = build(:animal).get_hungrier(60)
      expect(described_class.new(animal: lion, foods: [FoodCatalog.hay, FoodCatalog.banana]).foods).to eq([])
    end
  end
end
