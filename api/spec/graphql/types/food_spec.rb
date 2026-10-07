# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Food do
  let(:horse_meat) { FoodCatalog.find(:horse_meat) }

  describe 'code' do
    it '馬肉のカタログのキー "horse_meat" を返すこと' do
      expect(run_graphql_field('Food.code', horse_meat)).to eq('horse_meat')
    end
  end

  describe 'nameJa' do
    it '"馬肉" を返すこと' do
      expect(run_graphql_field('Food.nameJa', horse_meat)).to eq('馬肉')
    end
  end

  describe 'category' do
    it ':meat(FoodCategory の MEAT)を返すこと' do
      expect(Types::FoodCategory.coerce_isolated_result(run_graphql_field('Food.category', horse_meat))).to eq('MEAT')
    end
  end

  describe 'satiety' do
    it '35 を返すこと' do
      expect(run_graphql_field('Food.satiety', horse_meat)).to eq(35)
    end
  end
end
