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
  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new }
  let(:operatings) { in_memory::InMemoryOperatingRepository.new }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000), funds: shared::Money.yen(100_000))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals, housings, operatings]) }
  let(:no_outbreak) { instance_double(Random, rand: 99) }
  let(:service) do
    described_class.new(
      command: commands::RunDaysCommand.new(days: 3, random: no_outbreak).bind(
        animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:, operatings:, unit_of_work:
      )
    )
  end

  describe '#call' do
    it 'days=3 で進めると result.value が days=3 になり、寿命超過個体の老衰死を集計すること' do
      expect(service.call.value).to eq(days: 3, total_deaths: 1, deaths_by_cause: { old_age: 1 })
    end

    it 'days=3 で進めると /operate と同じ1日の運営が3回行われ、園の経過日数が3進み運営記録が3件残ること' do
      expect { service.call }.to change { zoo.load.day }.by(3)
      expect(operatings.all.map(&:day)).to eq([1, 2, 3])
    end

    it 'days=3 で進めると、園の収益の増分が3日分の運営記録の収入合計と一致すること' do
      before = zoo.load.revenue.yen
      service.call

      expect(zoo.load.revenue.yen - before).to eq(operatings.all.sum { |operating| operating.income.yen })
      expect(operatings.all.map { |operating| operating.income.yen }).to all(be_positive)
    end
  end
end
