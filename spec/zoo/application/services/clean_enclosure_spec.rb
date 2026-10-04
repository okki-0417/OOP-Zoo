# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::CleanEnclosure do
  shared    = Zoo::Domain::Shared
  taxonomy  = Zoo::Domain
  husbandry = Zoo::Domain
  staff     = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([keeper]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }

  def clean(command)
    described_class.new(command: command.bind(keepers:, enclosures:, housings:, unit_of_work:)).call
  end

  describe '#call' do
    it '清潔度20まで汚れたエリアを amount 50 で清掃すると level が70になり、value の EnclosureProfile の cleanliness も70であること' do
      enclosure.soil(80)

      result = clean(commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id, amount: 50))

      expect(enclosures.find(enclosure.id).cleanliness.level).to eq(70)
      expect(result.value).to have_attributes(id: enclosure.id.to_s, cleanliness: 70)
    end

    it 'amount 省略で呼ぶと level が100まで回復すること' do
      enclosure.soil(80)

      clean(commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id))

      expect(enclosures.find(enclosure.id).cleanliness.level).to eq(100)
    end

    it '収容中のライオンがいるとき value の EnclosureProfile の occupants にその個体が含まれること' do
      lion = build_adult(catalog.lion, name: 'レオ')
      housings.save(housed(lion, enclosure))

      result = clean(commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id))

      expect(result.value.occupants.map(&:name)).to eq(['レオ'])
    end

    it "存在しない keeper_id='missing' を渡すと failure で error が Application::Errors::KeeperNotFound となること" do
      result = clean(commands::CleanEnclosureCommand.new(keeper_id: 'missing', enclosure_id: enclosure.id))

      expect(result.error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end

    it "存在しない enclosure_id='missing' を渡すと failure で error が Application::Errors::EnclosureNotFound となること" do
      result = clean(commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: 'missing'))

      expect(result.error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
