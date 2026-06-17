# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::OperateDay do
  shared     = Zoo::Domain::Shared
  husbandry  = Zoo::Domain::Husbandry
  catalog    = Zoo::Domain::Taxonomy::SpeciesCatalog
  in_memory  = Zoo::Infrastructure::InMemory

  let(:zebra) { build_adult(catalog.grevys_zebra, name: 'シマオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
                        .tap { |e| e.admit(zebra) }
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([zebra]) }
  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000), funds: shared::Money.yen(100_000))
    )
  end
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:dispatcher) { Zoo::Application::EventDispatcher.new(event_store: event_store) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals]) }
  let(:open_for_a_day) do
    Zoo::Application::Services::OpenForADay.new(
      enclosures: enclosures, animals: animals, event_dispatcher: dispatcher, unit_of_work: unit_of_work
    )
  end

  let(:no_outbreak) { instance_double(Random, rand: 99) }
  let(:service) do
    described_class.new(
      open_for_a_day: open_for_a_day, enclosures: enclosures, animals: animals,
      keepers: keepers, veterinarians: veterinarians, zoo: zoo, unit_of_work: unit_of_work,
      random: no_outbreak
    )
  end

  describe '#call' do
    it '展示1種(EN)・評判50・料金¥2,000で来園12人を集め、収入¥24,000・費用を計上すること' do
      report = service.call

      zebra_food = catalog.grevys_zebra.daily_food_cost.yen
      upkeep = Zoo::Domain::Operations::OperatingCost::UPKEEP_PER_ENCLOSURE

      expect(report.visitors).to eq(12)
      expect(report.income).to eq(shared::Money.yen(24_000))
      expect(report.cost).to eq(shared::Money.yen(upkeep + zebra_food))
    end

    it '1日運営すると園の経過日数が1進むこと' do
      expect { service.call }.to change { zoo.load.day }.by(1)
    end

    it '死亡が無い日は評判が体験へドリフトするが、来場12人と露出が小さく単日では表示は据え置き(50のまま)、残高に純益が反映されること' do
      cost = Zoo::Domain::Operations::OperatingCost::UPKEEP_PER_ENCLOSURE +
             catalog.grevys_zebra.daily_food_cost.yen
      report = service.call

      expect(report.deaths).to eq(0)
      expect(report.reputation).to eq(50)
      expect(report.balance).to eq(shared::Balance.new(100_000 + 24_000 - cost))
      expect(report.bankrupt).to be(false)
    end

    it '疫病が発生する乱数だと在園個体が発病し、report.outbreak に名前が入ること' do
      outbreak_random = instance_double(Random)
      allow(outbreak_random).to receive(:rand).and_return(0)
      service = described_class.new(
        open_for_a_day: open_for_a_day, enclosures: enclosures, animals: animals,
        keepers: keepers, veterinarians: veterinarians, zoo: zoo, unit_of_work: unit_of_work,
        random: outbreak_random
      )

      report = service.call

      expect(report.outbreak).to eq('シマオ')
      expect(animals.find(zebra.id)).to be_sick
    end
  end
end
