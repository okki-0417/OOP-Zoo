# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::RenameAnimal do
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }

  def rename(animal_id, new_name)
    command = Zoo::Application::Commands::RenameAnimalCommand.new(animal_id:, new_name:)
                                                             .bind(animals:, housings:, unit_of_work:)
    described_class.new(command: command).call
  end

  describe '#call' do
    it 'new_name=\'シンバ\' で改名すると名前が変わり、result.value の animal の名前が \'シンバ\' になること' do
      animal = rename(lion.id, 'シンバ').value[:animal]

      expect(animals.find(lion.id).name.to_s).to eq('シンバ')
      expect(animal.name.to_s).to eq('シンバ')
    end

    it '存在しない animal_id=\'missing\' で result.error が Application::Errors::AnimalNotFound になること' do
      expect(rename('missing', 'X').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
