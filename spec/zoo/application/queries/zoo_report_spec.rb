# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::ZooReport do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:zebra) { build_adult(catalog.grevys_zebra, name: 'シマオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
  end
  let(:housings) { in_memory::InMemoryHousingRepository.new([housed(zebra, enclosure)]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new }
  let(:births) { in_memory::InMemoryBirthRepository.new }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000)))
  end

  let(:query) do
    described_class.new(
      command: commands::ZooReportCommand.new.bind(housings: housings, zoo: zoo, animals: animals, births: births)
    )
  end

  describe '#call' do
    it '在園・種数・絶滅危惧種数を集計すること' do
      stats = query.call.value

      expect(stats.population).to eq(1)
      expect(stats.species_count).to eq(1)
      expect(stats.threatened_count).to eq(1)
    end

    it '出生数は BirthRepository から、死因別死亡数は AnimalRepository から集計すること' do
      sire = build_adult(catalog.grevys_zebra, name: '父')
      dam = build_adult(catalog.grevys_zebra, name: '母', sex: Zoo::Domain::Animal::Sex.female)
      newborn = build_adult(catalog.grevys_zebra, name: '仔')
      births.save(Zoo::Domain::Birth.reconstitute(
                    id: Zoo::Domain::Shared::Identifier.new, sire: sire, dam: dam,
                    offspring: newborn, occurred_on: 0, season: Zoo::Domain::Season.spring
                  ))
      dead1 = build_adult(catalog.grevys_zebra, name: '死1')
      dead1.die(cause: :old_age)
      animals.save(dead1)
      dead2 = build_adult(catalog.grevys_zebra, name: '死2')
      dead2.die(cause: :starvation)
      animals.save(dead2)

      stats = query.call.value

      expect(stats.births).to eq(1)
      expect(stats.deaths_by_cause).to eq(old_age: 1, starvation: 1)
    end
  end
end
