# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::RunDays do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands
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
    described_class.new(
      command: commands::RunDaysCommand.new(days: 3).bind(enclosures:, animals:, housings:, unit_of_work:)
    )
  end

  describe '#call' do
    it 'days=3 で進めると result.value が days=3 の RunDaysSummary になり、寿命超過個体の老衰死を集計すること' do
      summary = service.call.value

      expect(summary.days).to eq(3)
      expect(summary.total_deaths).to eq(1)
      expect(summary.deaths_by_cause).to eq(old_age: 1)
    end
  end
end
