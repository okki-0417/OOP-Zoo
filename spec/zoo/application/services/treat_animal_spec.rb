# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::TreatAnimal do
  taxonomy  = Zoo::Domain::Taxonomy
  staff     = Zoo::Domain::Staff
  medical   = Zoo::Domain::Medical
  catalog   = taxonomy::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:penguin) { build_adult(catalog.emperor_penguin, name: 'ペン') }
  let(:vet) { staff::Veterinarian.new(name: '山田') }

  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new([vet]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([penguin]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(veterinarians: veterinarians, animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it '肺炎のペンギンを獣医が治療すると sick? が false になること' do
      penguin.fall_ill(medical::IllnessCatalog.pneumonia)

      service.call(commands::TreatAnimalCommand.new(veterinarian_id: vet.id, animal_id: penguin.id))

      expect(animals.find(penguin.id)).not_to be_sick
    end

    it '存在しない veterinarian_id=\'missing\' を渡すと Application::Errors::VeterinarianNotFound が発生すること' do
      command = commands::TreatAnimalCommand.new(veterinarian_id: 'missing', animal_id: penguin.id)

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::VeterinarianNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと Application::Errors::AnimalNotFound が発生すること' do
      command = commands::TreatAnimalCommand.new(veterinarian_id: vet.id, animal_id: 'missing')

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
