# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Keeper do
  let(:keeper) { create(:keeper, name: '田中', specialties: [TaxonClass.bird]) }

  it 'name・specialties・remainingMinutes は "田中"・[鳥類]・480 を返すこと' do
    expect(run_graphql_field('Keeper.name', keeper)).to eq('田中')
    expect(run_graphql_field('Keeper.specialties', keeper)).to eq([TaxonClass.bird])
    expect(run_graphql_field('Keeper.remainingMinutes', keeper)).to eq(480)
  end

  it 'enclosures は担当するエリアを返すこと' do
    pond = create(:enclosure, name: '池')
    keeper.enclosures << pond

    expect(run_graphql_field('Keeper.enclosures', keeper)).to eq([pond])
  end
end
