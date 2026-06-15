# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AddEnclosure do
  shared    = Zoo::Domain::Shared
  domain    = Zoo::Domain
  money     = Zoo::Domain::Shared::Money
  balance   = Zoo::Domain::Shared::Balance
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new }
  let(:funds) { 100_000 }
  let(:zoo_repo) do
    in_memory::InMemoryZooRepository.new(
      domain::Zoo.new(name: '動物園', admission_fee: money.yen(2_000), funds: money.yen(funds))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures]) }
  let(:service) { described_class.new(enclosures: enclosures, zoo: zoo_repo, unit_of_work: unit_of_work) }
  let(:command) do
    commands::AddEnclosureCommand.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  describe '#call' do
    it '採番された id で find できるエリアが保存されること' do
      enclosure = service.call(command)

      expect(enclosures.find(enclosure.id)).to eq(enclosure)
      expect(enclosure.name).to eq('ライオンの丘')
    end

    it '建設費(定員4で70,000円)ぶん残高が減ること' do
      service.call(command)

      expect(zoo_repo.load.balance).to eq(balance.new(30_000))
    end

    it '空の name を渡すと Enclosure の不変条件で ArgumentError が発生すること' do
      bad = commands::AddEnclosureCommand.new(name: '', temperature: shared::Temperature.celsius(28), capacity: 4)

      expect { service.call(bad) }.to raise_error(ArgumentError)
    end

    context '残高が建設費に満たないとき' do
      let(:funds) { 10_000 }

      it 'InsufficientFunds になり、エリアは保存されないこと' do
        expect { service.call(command) }.to raise_error(Zoo::Domain::Errors::InsufficientFunds)
        expect(enclosures.all).to be_empty
        expect(zoo_repo.load.balance).to eq(balance.new(10_000))
      end
    end
  end
end
