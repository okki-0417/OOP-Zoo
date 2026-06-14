# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::HireKeeper do
  taxonomy  = Zoo::Domain::Taxonomy
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [keepers]) }
  let(:service) { described_class.new(keepers: keepers, unit_of_work: unit_of_work) }

  describe '#call' do
    it 'name と専門綱を渡すと、採番された id で find できる飼育員が保存されること' do
      keeper = service.call(commands::HireKeeperCommand.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]))

      expect(keepers.find(keeper.id)).to eq(keeper)
      expect(keeper.name).to eq('田中')
    end

    it '空の specialties を渡すと Keeper の不変条件で ArgumentError が発生すること' do
      command = commands::HireKeeperCommand.new(name: '田中', specialties: [])

      expect { service.call(command) }.to raise_error(ArgumentError)
    end
  end
end
