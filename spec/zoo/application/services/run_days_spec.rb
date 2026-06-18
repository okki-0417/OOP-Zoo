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
                        .tap do |e|
      e.admit(survivor)
      e.admit(elder)
    end
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([survivor, elder]) }
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:dispatcher) { Zoo::Application::EventDispatcher.new(event_store: event_store) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals]) }
  let(:open_for_a_day) do
    Zoo::Application::Services::OpenForADay.new(
      enclosures: enclosures, animals: animals, event_dispatcher: dispatcher, unit_of_work: unit_of_work
    )
  end
  let(:service) { described_class.new(open_for_a_day: open_for_a_day) }

  describe '#call' do
    it '3日進めると days=3 のサマリを返し、寿命超過個体の老衰死を集計すること' do
      summary = service.call(commands::RunDaysCommand.new(days: 3))

      expect(summary.days).to eq(3)
      expect(summary.total_deaths).to eq(1)
      expect(summary.deaths_by_cause).to eq(old_age: 1)
    end
  end
end
