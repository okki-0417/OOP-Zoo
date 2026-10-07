# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::TransferAnimal do
  it 'transferAnimal(animalId: 丘にいるレオ, enclosureId: 草原) はレオを返し、レオが草原に移ること' do
    lion = create(:animal, name: 'レオ', enclosure: create(:enclosure))
    meadow = create(:enclosure)

    response = OopZooSchema.execute(%(mutation { transferAnimal(animalId: "#{lion.id}", enclosureId: "#{meadow.id}") { name } })).to_h

    expect(response).to eq('data' => { 'transferAnimal' => { 'name' => 'レオ' } })
    expect(lion.reload.enclosure).to eq(meadow)
  end
end
