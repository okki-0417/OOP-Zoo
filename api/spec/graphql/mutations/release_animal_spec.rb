# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::ReleaseAnimal do
  it 'releaseAnimal(animalId: 丘にいるレオ) はレオを返し、レオがどのエリアにもいなくなること' do
    lion = create(:animal, name: 'レオ', enclosure: create(:enclosure))

    response = OopZooSchema.execute(%(mutation { releaseAnimal(animalId: "#{lion.id}") { name } })).to_h

    expect(response).to eq('data' => { 'releaseAnimal' => { 'name' => 'レオ' } })
    expect(lion.reload.enclosure).to be_nil
  end
end
