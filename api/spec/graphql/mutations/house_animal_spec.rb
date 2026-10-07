# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::HouseAnimal do
  describe 'houseAnimal(enclosureId:, animalId:)' do
    subject(:response) do
      OopZooSchema.execute(%(mutation { houseAnimal(enclosureId: "#{hill.id}", animalId: "#{lion.id}") { name } })).to_h
    end

    let(:hill) { create(:enclosure, name: '丘') }
    let(:lion) { create(:animal) }

    it '丘を返すこと' do
      expect(response).to eq('data' => { 'houseAnimal' => { 'name' => '丘' } })
    end

    it 'ライオンを丘に収容すること' do
      response

      expect(lion.reload.enclosure).to eq(hill)
    end
  end
end
