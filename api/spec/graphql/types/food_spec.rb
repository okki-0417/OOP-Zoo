# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Food do
  let(:horse_meat) { FoodCatalog.find(:horse_meat) }

  it 'code は馬肉のカタログのキー "horse_meat" を返すこと' do
    expect(run_graphql_field('Food.code', horse_meat)).to eq('horse_meat')
  end

  it 'nameJa・category・satiety は "馬肉"・:meat(MEAT)・35 を返すこと' do
    expect(run_graphql_field('Food.nameJa', horse_meat)).to eq('馬肉')
    expect(Types::FoodCategory.coerce_isolated_result(run_graphql_field('Food.category', horse_meat))).to eq('MEAT')
    expect(run_graphql_field('Food.satiety', horse_meat)).to eq(35)
  end
end
