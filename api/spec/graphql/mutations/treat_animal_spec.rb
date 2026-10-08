# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::TreatAnimal do
  describe 'treatAnimal(animalId:, veterinarianId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { treatAnimal(animalId: "#{lion.id}", veterinarianId: "#{veterinarian.id}") { name sick } })
      ).to_h
    end

    let(:lion) { create(:animal, name: 'レオ').fall_ill(IllnessCatalog.cold).tap(&:save!) }
    let(:veterinarian) { create(:veterinarian) }

    it '風邪の治ったレオを sick=false で返すこと' do
      expect(response).to eq('data' => { 'treatAnimal' => { 'name' => 'レオ', 'sick' => false } })
    end

    it 'レオの回復を保存すること' do
      response

      expect(lion.reload).not_to be_sick
    end
  end
end
