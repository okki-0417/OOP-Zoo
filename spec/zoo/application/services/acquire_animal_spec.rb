# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AcquireAnimal do
  domain    = Zoo::Domain
  money     = Zoo::Domain::Shared::Money
  balance   = Zoo::Domain::Shared::Balance
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:animals) { in_memory::InMemoryAnimalRepository.new }
  let(:species) { in_memory::InMemorySpeciesRepository.new }
  let(:funds) { 100_000 }
  let(:zoo_repo) do
    in_memory::InMemoryZooRepository.new(
      domain::Zoo.new(name: '動物園', admission_fee: money.yen(2_000), funds: money.yen(funds))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }

  def acquire(species_code:, name:, sex: 'male')
    command = Zoo::Application::Commands::AcquireAnimalCommand.new(species_code:, name:, sex:)
    described_class.new(
      command: command.bind(animals:, species:, zoo: zoo_repo, unit_of_work:)
    ).call
  end

  describe '#call' do
    it 'species_code "japanese_macaque" で取得すると、採番 id で find できる個体が保存され、value の AnimalProfile に name "モンタ" が入ること' do
      profile = acquire(species_code: 'japanese_macaque', name: 'モンタ').value

      expect(profile).to be_a(Zoo::Application::ReadModels::AnimalProfile)
      expect(animals.find(profile.id).name).to eq('モンタ')
      expect(profile.name).to eq('モンタ')
      expect(profile.enclosure_id).to be_nil
    end

    it '取引可能な種(japanese_macaque)は取得価格ぶん残高が減ること' do
      acquire(species_code: 'japanese_macaque', name: 'モンタ')

      expected = 100_000 - catalog.japanese_macaque.acquisition_price.yen
      expect(zoo_repo.load.balance).to eq(balance.new(expected))
    end

    it '未知の species_code "dragon" を渡すと failure になり error が SpeciesNotFound であること' do
      result = acquire(species_code: 'dragon', name: 'X')

      expect(result.failure?).to be(true)
      expect(result.error).to be_a(Zoo::Application::Errors::SpeciesNotFound)
      expect(animals.all).to be_empty
    end

    it '未知の sex "other" を渡すと failure になり error が InvalidValue であること' do
      result = acquire(species_code: 'lion', name: 'レオ', sex: 'other')

      expect(result.error).to be_a(Zoo::Domain::Errors::InvalidValue)
    end

    it 'species_code が nil のとき AcquireAnimalCommand.new が ArgumentError になること' do
      expect { commands::AcquireAnimalCommand.new(species_code: nil, name: 'X', sex: 'male') }
        .to raise_error(ArgumentError)
    end

    context '残高(10,000円)が取得価格に満たないとき' do
      let(:funds) { 10_000 }

      it 'failure になり error が InsufficientFunds で、個体は保存されず残高も変わらないこと' do
        result = acquire(species_code: 'japanese_macaque', name: 'モンタ')

        expect(result.error).to be_a(Zoo::Domain::Errors::InsufficientFunds)
        expect(animals.all).to be_empty
        expect(zoo_repo.load.balance).to eq(balance.new(10_000))
      end
    end

    context '絶滅危惧種(species_code "lion" = VU)のとき' do
      it '購入されず(繁殖プログラムから無償で受け入れ)、残高が 100,000円のまま個体が1件保存されること' do
        acquire(species_code: 'lion', name: 'レオ')

        expect(zoo_repo.load.balance).to eq(balance.new(100_000))
        expect(animals.all.size).to eq(1)
      end

      it '保全への貢献として zoo.reputation が上がること' do
        before = zoo_repo.load.reputation
        acquire(species_code: 'lion', name: 'レオ')

        expect(zoo_repo.load.reputation).to be > before
      end
    end
  end
end
