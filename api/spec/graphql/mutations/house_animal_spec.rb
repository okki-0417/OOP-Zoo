# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::HouseAnimal do
  it 'houseAnimal(enclosureId: 丘, animalId: レオ) は丘を返し、レオが丘に収容されること' do
    hill = create(:enclosure, name: '丘')
    lion = create(:animal)

    response = OopZooSchema.execute(%(mutation { houseAnimal(enclosureId: "#{hill.id}", animalId: "#{lion.id}") { name } })).to_h

    expect(response).to eq('data' => { 'houseAnimal' => { 'name' => '丘' } })
    expect(lion.reload.enclosure).to eq(hill)
  end
end
