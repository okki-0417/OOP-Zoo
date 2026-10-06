# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::TreatAnimal do
  taxonomy  = Zoo::Domain
  staff     = Zoo::Domain
  medical   = Zoo::Domain
  catalog   = taxonomy::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:penguin) { build_adult(catalog.emperor_penguin, name: 'ペン') }
  let(:vet) { staff::Veterinarian.new(name: '山田') }

  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new([vet]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([penguin]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }

  def treat(veterinarian_id:, animal_id:)
    command = Zoo::Application::Commands::TreatAnimalCommand.new(veterinarian_id:, animal_id:)
                                                            .bind(veterinarians:, animals:, unit_of_work:)
    described_class.new(command: command).call
  end

  describe '#call' do
    it '肺炎のペンギンを獣医が治療すると sick? が false になり、result.value の illness_name が nil になること' do
      penguin.fall_ill(medical::IllnessCatalog.pneumonia)

      animal = treat(veterinarian_id: vet.id, animal_id: penguin.id).value

      expect(animals.find(penguin.id)).not_to be_sick
      expect(animal.illness_name).to be_nil
    end

    it '存在しない veterinarian_id=\'missing\' を渡すと result.error が Application::Errors::VeterinarianNotFound になること' do
      result = treat(veterinarian_id: 'missing', animal_id: penguin.id)

      expect(result.error).to be_a(Zoo::Application::Errors::VeterinarianNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が Application::Errors::AnimalNotFound になること' do
      result = treat(veterinarian_id: vet.id, animal_id: 'missing')

      expect(result.error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
