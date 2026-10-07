# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::TransferAnimal do
  describe 'transferAnimal(animalId:, enclosureId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { transferAnimal(animalId: "#{lion.id}", enclosureId: "#{meadow.id}") { name } })
      ).to_h
    end

    let(:lion) { create(:animal, name: 'レオ', enclosure: create(:enclosure)) }
    let(:meadow) { create(:enclosure) }

    it 'レオを返すこと' do
      expect(response).to eq('data' => { 'transferAnimal' => { 'name' => 'レオ' } })
    end

    it 'レオを草原に移すこと' do
      response

      expect(lion.reload.enclosure).to eq(meadow)
    end
  end
end
