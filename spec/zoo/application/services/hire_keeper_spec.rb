# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::HireKeeper do
  taxonomy  = Zoo::Domain::Taxonomy
  domain    = Zoo::Domain
  money     = Zoo::Domain::Shared::Money
  balance   = Zoo::Domain::Shared::Balance
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:funds) { 100_000 }
  let(:zoo_repo) do
    in_memory::InMemoryZooRepository.new(
      domain::Zoo.new(name: '動物園', admission_fee: money.yen(2_000), funds: money.yen(funds))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [keepers]) }
  let(:service) { described_class.new(keepers: keepers, zoo: zoo_repo, unit_of_work: unit_of_work) }
  let(:command) { commands::HireKeeperCommand.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }

  describe '#call' do
    it '採番された id で find できる飼育員が保存されること' do
      keeper = service.call(command)

      expect(keepers.find(keeper.id)).to eq(keeper)
      expect(keeper.name).to eq('田中')
    end

    it '採用の一時金(20,000円)ぶん残高が減ること' do
      service.call(command)

      expect(zoo_repo.load.balance).to eq(balance.new(80_000))
    end

    it '空の specialties を渡すと Keeper の不変条件で ArgumentError が発生すること' do
      bad = commands::HireKeeperCommand.new(name: '田中', specialties: [])

      expect { service.call(bad) }.to raise_error(ArgumentError)
    end

    context '残高が一時金に満たないとき' do
      let(:funds) { 10_000 }

      it 'InsufficientFunds になり、飼育員は保存されないこと' do
        expect { service.call(command) }.to raise_error(Zoo::Domain::Errors::InsufficientFunds)
        expect(keepers.all).to be_empty
        expect(zoo_repo.load.balance).to eq(balance.new(10_000))
      end
    end
  end
end
