# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::OperateDay do
  shared     = Zoo::Domain::Shared
  husbandry  = Zoo::Domain
  catalog    = Zoo::Domain::SpeciesCatalog
  in_memory  = Zoo::Infrastructure::InMemory

  let(:zebra) { build_adult(catalog.grevys_zebra, name: 'シマオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([zebra]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new([housed(zebra, enclosure)]) }
  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new }
  let(:operatings) { in_memory::InMemoryOperatingRepository.new }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000), funds: shared::Money.yen(100_000))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals, housings]) }

  let(:no_outbreak) { instance_double(Random, rand: 99) }
  let(:service) { operate_with(no_outbreak) }

  def operate_with(random)
    command = Zoo::Application::Commands::OperateDayCommand.new(random:).bind(
      animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:, operatings:, unit_of_work:
    )
    described_class.new(command: command)
  end

  describe '#call' do
    it '展示1種(EN)・評判50・料金¥2,000で来園12人を集め、result.value の Operating に収入¥24,000・費用を計上すること' do
      report = service.call.value

      zebra_food = catalog.grevys_zebra.daily_food_cost.yen
      upkeep = Zoo::Domain::Enclosure::UPKEEP_YEN

      expect(report.visitors).to eq(12)
      expect(report.income).to eq(shared::Money.yen(24_000))
      expect(report.cost).to eq(shared::Money.yen(upkeep + zebra_food))
    end

    it '同じ種(グレビーシマウマ)が2頭いれば、飼料費は2頭分を計上すること' do
      second = build_adult(catalog.grevys_zebra, name: 'シマコ', sex: Zoo::Domain::Animal::Sex.female)
      animals.save(second)
      housings.save(housed(second, enclosure))

      report = service.call.value

      zebra_food = catalog.grevys_zebra.daily_food_cost.yen
      expect(report.cost).to eq(shared::Money.yen(Zoo::Domain::Enclosure::UPKEEP_YEN + (zebra_food * 2)))
    end

    it '1日運営すると園の経過日数が1進むこと' do
      expect { service.call }.to change { zoo.load.day }.by(1)
    end

    it '1日運営すると運営記録(Operating)が履歴に残ること' do
      service.call

      record = operatings.all.last
      expect(operatings.all.size).to eq(1)
      expect(record.day).to eq(1)
      expect(record.visitors).to eq(12)
      expect(record.income).to eq(shared::Money.yen(24_000))
    end

    it '死亡が無い日は評判が体験へドリフトするが、来場12人と露出が小さく単日では表示は据え置き(50のまま)、残高に純益が反映されること' do
      cost = Zoo::Domain::Enclosure::UPKEEP_YEN +
             catalog.grevys_zebra.daily_food_cost.yen
      report = service.call.value

      expect(report.deaths).to eq(0)
      expect(report.reputation).to eq(50)
      expect(report.balance).to eq(shared::Balance.new(100_000 + 24_000 - cost))
      expect(report.balance).not_to be_negative
    end

    it '感染源と同居していても、伝播しない乱数(rand=99 ≥ 伝播確率50%)なら同居個体は発病しないこと' do
      carrier = build_adult(catalog.grevys_zebra, name: '感染源', sex: Zoo::Domain::Animal::Sex.female)
      carrier.fall_ill(Zoo::Domain::IllnessCatalog.cold)
      animals.save(carrier)
      housings.save(housed(carrier, enclosure))

      service.call

      expect(animals.find(zebra.id)).not_to be_sick
    end

    it '感染源と同居していて、伝播する乱数(rand=0)なら同居個体に感染すること' do
      carrier = build_adult(catalog.grevys_zebra, name: '感染源', sex: Zoo::Domain::Animal::Sex.female)
      carrier.fall_ill(Zoo::Domain::IllnessCatalog.cold)
      animals.save(carrier)
      housings.save(housed(carrier, enclosure))

      operate_with(instance_double(Random, rand: 0)).call

      expect(animals.find(zebra.id).illness).to eq(Zoo::Domain::IllnessCatalog.cold)
    end

    it '疫病が発生する乱数(rand=0)だと在園個体が発病し、result.value.outbreak に名前が入ること' do
      outbreak_random = instance_double(Random)
      allow(outbreak_random).to receive(:rand).and_return(0)

      report = operate_with(outbreak_random).call.value

      expect(report.outbreak).to eq('シマオ')
      expect(animals.find(zebra.id)).to be_sick
    end

    it '1日を締めると、その日200分働いた飼育員の勤務時間がリセットされ保存されること' do
      keeper = build_keeper.clock_in(200)
      keepers.save(keeper)

      service.call

      expect(keepers.find(keeper.id).remaining_minutes).to eq(480)
    end

    it 'その日に死亡した個体を result.value.casualties で返すこと' do
      elder = build_animal(catalog.grevys_zebra, name: '老', age_in_days: 1_000_000)
      animals.save(elder)
      housings.save(housed(elder, enclosure))

      expect(service.call.value.casualties.map(&:name)).to eq(['老'])
    end
  end
end
