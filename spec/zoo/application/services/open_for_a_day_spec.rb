# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::OpenForADay do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:survivor) { build_adult(catalog.lion, name: '若') }
  let(:elder) { build_animal(catalog.lion, name: '老', age_in_days: 1_000_000) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([survivor, elder]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new([housed(survivor, enclosure), housed(elder, enclosure)]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals, housings]) }
  let(:service) do
    described_class.new(enclosures: enclosures, animals: animals, housings: housings,
                        unit_of_work: unit_of_work)
  end

  describe '#call' do
    it '生存個体が1日歳をとること' do
      expect { service.call }.to change { survivor.age_in_days }.by(1)
    end

    it 'エリアが頭数ぶん汚れて cleanliness.level が100未満になること' do
      service.call

      expect(enclosures.find(enclosure.id).cleanliness.level).to be < 100
    end

    it '寿命を超えた個体は死亡してエリアの occupants から外れ、戻り値に含まれること' do
      dead = service.call

      expect(dead).to include(elder)
      expect(occupants_of(housings, enclosure)).not_to include(elder)
    end
  end
end
