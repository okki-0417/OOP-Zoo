# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AddEnclosure do
  domain    = Zoo::Domain
  money     = Zoo::Domain::Shared::Money
  balance   = Zoo::Domain::Shared::Balance
  in_memory = Zoo::Infrastructure::InMemory

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new }
  let(:funds) { 100_000 }
  let(:zoo_repo) do
    in_memory::InMemoryZooRepository.new(
      domain::Zoo.new(name: '動物園', admission_fee: money.yen(2_000), funds: money.yen(funds))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures]) }

  def add(name: 'ライオンの丘', celsius: 28, capacity: 4, climate_controlled: false)
    command = Zoo::Application::Commands::AddEnclosureCommand.new(name:, celsius:, capacity:, climate_controlled:)
    described_class.new(command: command.bind(enclosures:, zoo: zoo_repo, unit_of_work:)).call
  end

  describe '#call' do
    it 'name "ライオンの丘" で建設すると、採番 id で find できるエリアが保存され、value が occupants・keepers とも空のそのエリアであること' do
      view = add.value

      expect(enclosures.find(view[:enclosure].id).name).to eq('ライオンの丘')
      expect(view[:enclosure].capacity).to eq(4)
      expect(view).to include(occupants: [], keepers: [])
    end

    it '建設費(capacity 4 で 70,000円)ぶん残高が減ること' do
      add

      expect(zoo_repo.load.balance).to eq(balance.new(30_000))
    end

    context '資金が 200,000円 のとき' do
      let(:funds) { 200_000 }

      it 'climate_controlled=true なら空調付きで建ち、建設費 70,000円 + 空調 50,000円 で残高 80,000円 になること' do
        enclosure = add(climate_controlled: true).value[:enclosure]

        expect(enclosure).to be_climate_controlled
        expect(zoo_repo.load.balance).to eq(balance.new(80_000))
      end
    end

    it '空の name "" を渡すと Enclosure の不変条件で ArgumentError が発生すること' do
      expect { add(name: '') }.to raise_error(ArgumentError)
    end

    context '残高(10,000円)が建設費に満たないとき' do
      let(:funds) { 10_000 }

      it 'failure になり error が InsufficientFunds で、エリアは保存されず残高も変わらないこと' do
        result = add

        expect(result.error).to be_a(Zoo::Domain::Errors::InsufficientFunds)
        expect(enclosures.all).to be_empty
        expect(zoo_repo.load.balance).to eq(balance.new(10_000))
      end
    end
  end
end
