# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ExamineAnimal do
  describe 'examineAnimal(animalId:, veterinarianId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { examineAnimal(animalId: "#{lion.id}", veterinarianId: "#{veterinarian.id}") { animal { name } diagnosis } })
      ).to_h
    end

    let(:lion) { create(:animal, name: 'レオ') }
    let(:veterinarian) { create(:veterinarian) }

    it '健康なレオと diagnosis HEALTHY を返すこと' do
      expect(response).to eq('data' => { 'examineAnimal' => { 'animal' => { 'name' => 'レオ' }, 'diagnosis' => 'HEALTHY' } })
    end
  end
end
