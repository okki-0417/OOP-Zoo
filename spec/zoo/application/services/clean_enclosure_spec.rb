# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::CleanEnclosure do
  shared    = Zoo::Domain::Shared
  taxonomy  = Zoo::Domain::Taxonomy
  husbandry = Zoo::Domain::Husbandry
  staff     = Zoo::Domain::Staff
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([keeper]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(keepers: keepers, enclosures: enclosures, unit_of_work: unit_of_work) }

  describe '#call' do
    it '清潔度20まで汚れたエリアを清掃量50で清掃すると level が70になること' do
      enclosure.soil(80)

      service.call(commands::CleanEnclosureCommand.new(
                     keeper_id: keeper.id, enclosure_id: enclosure.id, amount: 50
                   ))

      expect(enclosures.find(enclosure.id).cleanliness.level).to eq(70)
    end

    it 'amount 省略で呼ぶと level が100まで回復すること' do
      enclosure.soil(80)

      service.call(commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id))

      expect(enclosures.find(enclosure.id).cleanliness.level).to eq(100)
    end

    it '存在しない keeper_id=\'missing\' を渡すと Application::Errors::KeeperNotFound が発生すること' do
      command = commands::CleanEnclosureCommand.new(keeper_id: 'missing', enclosure_id: enclosure.id)

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id=\'missing\' を渡すと Application::Errors::EnclosureNotFound が発生すること' do
      command = commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: 'missing')

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
