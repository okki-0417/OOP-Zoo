# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::ExamineAnimal do
  let!(:penguin) { build_adult(SpeciesCatalog.emperor_penguin, name: 'ペン').tap(&:save!) }
  let!(:vet) { Veterinarian.create!(name: '山田') }

  def examine(veterinarian_id: vet.id, animal_id: penguin.id)
    command = Services::Commands::ExamineAnimalCommand.new(veterinarian_id:, animal_id:)
    described_class.new(command:).call
  end

  describe '#call' do
    it '健康な個体を診ると value が { animal: その個体, diagnosis: :healthy } になること' do
      expect(examine.value).to eq(animal: penguin, diagnosis: :healthy)
    end

    it '肺炎の個体を診ると value.diagnosis が :sick になること' do
      penguin.fall_ill(IllnessCatalog.pneumonia).save!

      expect(examine.value[:diagnosis]).to eq(:sick)
    end

    it "存在しない veterinarian_id='missing' で failure になり error が Application::Errors::VeterinarianNotFound となること" do
      expect(examine(veterinarian_id: 'missing').error).to be_a(Services::Errors::VeterinarianNotFound)
    end

    it "存在しない animal_id='missing' で failure になり error が Application::Errors::AnimalNotFound となること" do
      expect(examine(animal_id: 'missing').error).to be_a(Services::Errors::AnimalNotFound)
    end
  end
end
