# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ReleaseAnimal do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new([housed(lion, enclosure)]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals, housings]) }
  let(:service) do
    described_class.new(animals: animals, housings: housings, unit_of_work: unit_of_work)
  end

  describe '#call' do
    it '収容中の個体を退去させるとエリアの occupants から外れること' do
      service.call(commands::ReleaseAnimalCommand.new(animal_id: lion.id))

      expect(occupants_of(housings, enclosure)).not_to include(lion)
    end

    it 'どのエリアにも収容されていない個体だと ArgumentError になること' do
      loose = build_adult(catalog.lion, name: '野良')
      animals.save(loose)

      expect { service.call(commands::ReleaseAnimalCommand.new(animal_id: loose.id)) }
        .to raise_error(ArgumentError, /収容されていません/)
    end
  end
end
