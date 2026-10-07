# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::TreatAnimal do
  let!(:penguin) do
    build_adult(SpeciesCatalog.emperor_penguin, name: 'ペン')
      .fall_ill(IllnessCatalog.pneumonia).tap(&:save!)
  end
  let!(:vet) { Veterinarian.create!(name: '山田') }

  def treat(veterinarian_id:, animal_id:)
    command = Services::Commands::TreatAnimalCommand.new(veterinarian_id:, animal_id:)
    described_class.new(command:).call
  end

  describe '#call' do
    it '肺炎のペンギンを獣医が治療すると保存された sick? が false になり、result.value の illness_name が nil になること' do
      animal = treat(veterinarian_id: vet.id, animal_id: penguin.id).value

      expect(penguin.reload).not_to be_sick
      expect(animal.illness_name).to be_nil
    end

    it '存在しない veterinarian_id=\'missing\' を渡すと result.error が Application::Errors::VeterinarianNotFound になること' do
      result = treat(veterinarian_id: 'missing', animal_id: penguin.id)

      expect(result.error).to be_a(Services::Errors::VeterinarianNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が Application::Errors::AnimalNotFound になること' do
      result = treat(veterinarian_id: vet.id, animal_id: 'missing')

      expect(result.error).to be_a(Services::Errors::AnimalNotFound)
    end
  end
end
