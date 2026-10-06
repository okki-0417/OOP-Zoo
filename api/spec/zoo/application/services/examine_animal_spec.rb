# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ExamineAnimal do
  taxonomy  = Zoo::Domain
  staff     = Zoo::Domain
  medical   = Zoo::Domain
  in_memory = Zoo::Infrastructure::InMemory

  let(:penguin) { build_adult(taxonomy::SpeciesCatalog.emperor_penguin, name: 'ペン') }
  let(:vet) { staff::Veterinarian.new(name: '山田') }

  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new([vet]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([penguin]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }

  def examine(veterinarian_id: vet.id, animal_id: penguin.id)
    command = Zoo::Application::Commands::ExamineAnimalCommand.new(veterinarian_id:, animal_id:)
    described_class.new(command: command.bind(veterinarians:, animals:, unit_of_work:)).call
  end

  describe '#call' do
    it '健康な個体を診ると value が { animal: その個体, diagnosis: :healthy } になること' do
      expect(examine.value).to eq(animal: penguin, diagnosis: :healthy)
    end

    it '肺炎の個体を診ると value.diagnosis が :sick になること' do
      penguin.fall_ill(medical::IllnessCatalog.pneumonia)

      expect(examine.value[:diagnosis]).to eq(:sick)
    end

    it "存在しない veterinarian_id='missing' で failure になり error が Application::Errors::VeterinarianNotFound となること" do
      expect(examine(veterinarian_id: 'missing').error).to be_a(Zoo::Application::Errors::VeterinarianNotFound)
    end
  end
end
