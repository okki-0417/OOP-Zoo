# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AcquireAnimal do
  animal    = Zoo::Domain::Animal
  domain    = Zoo::Domain
  money     = Zoo::Domain::Shared::Money
  balance   = Zoo::Domain::Shared::Balance
  pricing   = Zoo::Domain::Operations::Pricing
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:animals) { in_memory::InMemoryAnimalRepository.new }
  let(:funds) { 100_000 }
  let(:zoo_repo) do
    in_memory::InMemoryZooRepository.new(
      domain::Zoo.new(name: '動物園', admission_fee: money.yen(2_000), funds: money.yen(funds))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }
  let(:service) { described_class.new(animals: animals, zoo: zoo_repo, unit_of_work: unit_of_work) }

  let(:command) do
    commands::AcquireAnimalCommand.new(species: catalog.japanese_macaque, name: 'モンタ', sex: animal::Sex.male,
                                       max_health: 100)
  end

  describe '#call' do
    it '採番された id で find できる個体が保存されること' do
      acquired = service.call(command)

      expect(animals.find(acquired.id)).to eq(acquired)
      expect(acquired.name.to_s).to eq('モンタ')
    end

    it '取引可能な種は取得価格ぶん残高が減ること' do
      service.call(command)

      expected = 100_000 - pricing.acquisition_price(catalog.japanese_macaque).yen
      expect(zoo_repo.load.balance).to eq(balance.new(expected))
    end

    context '残高が取得価格に満たないとき' do
      let(:funds) { 10_000 }

      it 'InsufficientFunds になり、個体は保存されないこと' do
        expect { service.call(command) }.to raise_error(Zoo::Domain::Errors::InsufficientFunds)
        expect(animals.all).to be_empty
        expect(zoo_repo.load.balance).to eq(balance.new(10_000))
      end
    end

    context '絶滅危惧種(ライオン=VU)のとき' do
      let(:lion_command) do
        commands::AcquireAnimalCommand.new(species: catalog.lion, name: 'レオ', sex: animal::Sex.male, max_health: 100)
      end

      it '購入されず(繁殖プログラムから無償で受け入れ)、残高が変わらないこと' do
        service.call(lion_command)
        expect(zoo_repo.load.balance).to eq(balance.new(100_000))
        expect(animals.all.size).to eq(1)
      end

      it '保全への貢献として評判が上がること' do
        before = zoo_repo.load.reputation
        service.call(lion_command)
        expect(zoo_repo.load.reputation).to be > before
      end
    end
  end
end
