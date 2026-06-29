# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::NameAnimal do
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:animal) { build_adult(catalog.lion, name: 'ライオンの赤ちゃん', sex: Zoo::Domain::Animal::Sex.female) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([animal]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }
  let(:service) { described_class.new(animals: animals, unit_of_work: unit_of_work) }

  def command(animal_id: animal.id, name: 'ナラ')
    Zoo::Application::Commands::NameAnimalCommand.new(animal_id: animal_id, name: name)
  end

  describe '#call' do
    it '動物の名前が更新されること' do
      service.call(command(name: 'ナラ'))
      expect(animals.find(animal.id).name.to_s).to eq('ナラ')
    end

    it '存在しない animal_id を渡すと AnimalNotFound が発生すること' do
      expect { service.call(command(animal_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
