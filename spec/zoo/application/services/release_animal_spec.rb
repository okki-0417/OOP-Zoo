# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ReleaseAnimal do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| e.admit(lion) }
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals]) }
  let(:service) { described_class.new(enclosures: enclosures, animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it '収容中の個体を退去させるとエリアの occupants から外れること' do
      service.call(commands::ReleaseAnimalCommand.new(animal_id: lion.id))

      expect(enclosures.find(enclosure.id).occupants).not_to include(lion)
    end

    it 'どのエリアにも収容されていない個体だと ArgumentError になること' do
      loose = build_adult(catalog.lion, name: '野良')
      animals.save(loose)

      expect { service.call(commands::ReleaseAnimalCommand.new(animal_id: loose.id)) }
        .to raise_error(ArgumentError, /収容されていません/)
    end
  end
end
