# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::TransferAnimal do
  describe 'transferAnimal(animalId:, enclosureId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { transferAnimal(animalId: "#{lion.id}", enclosureId: "#{meadow.id}") { name } }),
        context: { current_zoo: zoo }
      ).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:lion) { create(:animal, zoo:, name: 'レオ', enclosure: create(:enclosure, zoo:)) }
    let(:meadow) { create(:enclosure, zoo:) }

    it 'レオを返すこと' do
      expect(response).to eq('data' => { 'transferAnimal' => { 'name' => 'レオ' } })
    end

    it 'レオを草原に移すこと' do
      response

      expect(lion.reload.enclosure).to eq(meadow)
    end
  end
end
