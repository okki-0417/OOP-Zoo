# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ExamineAnimal do
  taxonomy  = Zoo::Domain
  staff     = Zoo::Domain
  medical   = Zoo::Domain
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:penguin) { build_adult(taxonomy::SpeciesCatalog.emperor_penguin, name: 'ペン') }
  let(:vet) { staff::Veterinarian.new(name: '山田') }

  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new([vet]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([penguin]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(veterinarians: veterinarians, animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it '健康な個体を診ると :healthy を返すこと' do
      command = commands::ExamineAnimalCommand.new(veterinarian_id: vet.id, animal_id: penguin.id)

      expect(service.call(command)).to eq(:healthy)
    end

    it '肺炎の個体を診ると :sick を返すこと' do
      penguin.fall_ill(medical::IllnessCatalog.pneumonia)
      command = commands::ExamineAnimalCommand.new(veterinarian_id: vet.id, animal_id: penguin.id)

      expect(service.call(command)).to eq(:sick)
    end

    it '存在しない veterinarian_id=\'missing\' で Application::Errors::VeterinarianNotFound が発生すること' do
      command = commands::ExamineAnimalCommand.new(veterinarian_id: 'missing', animal_id: penguin.id)

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::VeterinarianNotFound)
    end
  end
end
