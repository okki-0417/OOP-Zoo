# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::RenameAnimal do
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }
  let(:service) { described_class.new(animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it '改名すると名前が変わること' do
      service.call(commands::RenameAnimalCommand.new(animal_id: lion.id, new_name: 'シンバ'))

      expect(animals.find(lion.id).name.to_s).to eq('シンバ')
    end

    it '存在しない animal_id で Application::Errors::AnimalNotFound が発生すること' do
      command = commands::RenameAnimalCommand.new(animal_id: 'missing', new_name: 'X')

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
