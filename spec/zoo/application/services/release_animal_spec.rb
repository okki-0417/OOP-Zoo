# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ReleaseAnimal do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new([housed(lion, enclosure)]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals, housings]) }

  def release(animal_id)
    command = Zoo::Application::Commands::ReleaseAnimalCommand.new(animal_id:).bind(animals:, housings:, unit_of_work:)
    described_class.new(command: command).call
  end

  describe '#call' do
    it '収容中の個体を退去させるとエリアの occupants から外れること' do
      release(lion.id)

      expect(occupants_of(housings, enclosure)).not_to include(lion)
    end

    it '退去に成功すると result.value が { animal: レオ, enclosure: nil } になること' do
      expect(release(lion.id).value).to eq(animal: lion, enclosure: nil)
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が AnimalNotFound になること' do
      expect(release('missing').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end

    it 'どのエリアにも収容されていない個体だと ArgumentError になること' do
      loose = build_adult(catalog.lion, name: '野良')
      animals.save(loose)

      expect { release(loose.id) }
        .to raise_error(ArgumentError, /収容されていません/)
    end
  end
end
