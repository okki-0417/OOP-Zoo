# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ExamineAnimal do
  describe 'examineAnimal(animalId:, veterinarianId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { examineAnimal(animalId: "#{lion.id}", veterinarianId: "#{veterinarian.id}") { animal { name } diagnosis } }),
        context: { current_zoo: zoo }
      ).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:lion) { create(:animal, zoo:, name: 'レオ') }
    let(:veterinarian) { create(:veterinarian, zoo:) }

    it '健康なレオと diagnosis HEALTHY を返すこと' do
      expect(response).to eq('data' => { 'examineAnimal' => { 'animal' => { 'name' => 'レオ' }, 'diagnosis' => 'HEALTHY' } })
    end
  end
end
