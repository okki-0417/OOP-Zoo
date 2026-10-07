# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Enclosure do
  let(:hill) { create(:enclosure, name: 'ライオンの丘', celsius: 28, capacity: 4) }

  it 'celsius・enrichment は 28℃・刺激度100のエリアで 28.0・100 を返すこと' do
    expect(run_graphql_field('Enclosure.celsius', hill)).to eq(28.0)
    expect(run_graphql_field('Enclosure.enrichment', hill)).to eq(100)
  end

  it 'occupants はレオと死亡したナラがいるとき、生きているレオだけを返すこと' do
    leo = create(:animal, name: 'レオ', enclosure: hill)
    create(:animal, :female, name: 'ナラ', enclosure: hill).die.save!

    expect(run_graphql_field('Enclosure.occupants', hill.reload)).to eq([leo])
  end

  it 'keepers は担当の飼育員を返すこと' do
    keeper = create(:keeper)
    keeper.enclosures << hill

    expect(run_graphql_field('Enclosure.keepers', hill)).to eq([keeper])
  end

  it 'occupancy は定員4に1頭の Occupancy(full?=false)を返すこと' do
    create(:animal, enclosure: hill)

    expect(run_graphql_field('Enclosure.occupancy', hill)).to have_attributes(class: Occupancy, full?: false)
  end
end
