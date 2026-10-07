# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::OperateDay do
  let!(:zoo) { create(:zoo) }
  let!(:enclosure) { create(:enclosure, name: 'サバンナ', celsius: 30, capacity: 6) }
  let!(:zebra) { house(build(:animal, species: SpeciesCatalog.grevys_zebra, name: 'シマオ')) }

  let(:no_outbreak) { instance_double(Random, rand: 99) }
  let(:service) { operate_with(no_outbreak) }

  def operate_with(random)
    described_class.new(command: Services::Commands::OperateDayCommand.new(random:))
  end

  def house(animal)
    animal.move_to(enclosure).tap(&:save!)
  end

  def house_carrier
    carrier = build(:animal, :female, species: SpeciesCatalog.grevys_zebra, name: '感染源')
    house(carrier.fall_ill(IllnessCatalog.cold))
  end

  describe '#call' do
    it '展示1種(EN)・評判50・料金¥2,000で来園12人を集め、result.value の Operating に収入¥24,000・費用を計上すること' do
      report = service.call.value

      zebra_food = SpeciesCatalog.grevys_zebra.daily_food_cost.yen
      upkeep = Enclosure::UPKEEP_YEN

      expect(report.visitors).to eq(12)
      expect(report.income).to eq(Money.yen(24_000))
      expect(report.cost).to eq(Money.yen(upkeep + zebra_food))
    end

    it '同じ種(グレビーシマウマ)が2頭いれば、飼料費は2頭分を計上すること' do
      house(build(:animal, :female, species: SpeciesCatalog.grevys_zebra, name: 'シマコ'))

      report = service.call.value

      zebra_food = SpeciesCatalog.grevys_zebra.daily_food_cost.yen
      expect(report.cost).to eq(Money.yen(Enclosure::UPKEEP_YEN + (zebra_food * 2)))
    end

    it '1日運営すると、施設維持費(サバンナ)と飼料費(グレビーシマウマ×1)の内訳が保存された運営記録に残ること' do
      service.call

      expect(Operating.latest.expenses.map(&:to_s)).to eq(
        [
          "施設維持費 サバンナ #{Money.yen(Enclosure::UPKEEP_YEN)}",
          "飼料費 グレビーシマウマ #{SpeciesCatalog.grevys_zebra.daily_food_cost}"
        ]
      )
    end

    it '1日運営すると保存された園の経過日数が1進むこと' do
      expect { service.call }.to change { zoo.reload.day }.by(1)
    end

    it '1日運営すると運営記録(Operating)が1件保存され、day=1・来園12人・収入¥24,000 であること' do
      service.call

      record = Operating.latest
      expect(Operating.count).to eq(1)
      expect(record.day).to eq(1)
      expect(record.visitors).to eq(12)
      expect(record.income).to eq(Money.yen(24_000))
    end

    it '死亡が無い日は評判が体験へドリフトするが、来場12人と露出が小さく単日では表示は据え置き(50のまま)、残高に純益が反映されること' do
      cost = Enclosure::UPKEEP_YEN + SpeciesCatalog.grevys_zebra.daily_food_cost.yen
      report = service.call.value

      expect(report.deaths).to eq(0)
      expect(report.reputation).to eq(50)
      expect(report.balance).to eq(Balance.new(100_000 + 24_000 - cost))
      expect(zoo.reload.balance).to eq(Balance.new(100_000 + 24_000 - cost))
    end

    it '1日運営するとサバンナが1頭分汚れ(清潔度99)、刺激度が2下がって(98)保存されること' do
      service.call

      expect(enclosure.reload).to have_attributes(cleanliness_level: 99)
      expect(enclosure.enrichment.level).to eq(98)
    end

    it '感染源と同居していても、伝播しない乱数(rand=99 ≥ 伝播確率50%)なら同居個体は発病しないこと' do
      house_carrier

      service.call

      expect(zebra.reload).not_to be_sick
    end

    it '感染源と同居していて、伝播する乱数(rand=0)なら同居個体に感染して保存されること' do
      house_carrier

      operate_with(instance_double(Random, rand: 0)).call

      expect(zebra.reload.illness).to eq(IllnessCatalog.cold)
    end

    it '疫病が発生する乱数(rand=0)だと在園個体が発病し、result.value.outbreak に名前が入ること' do
      outbreak_random = instance_double(Random)
      allow(outbreak_random).to receive(:rand).and_return(0)

      report = operate_with(outbreak_random).call.value

      expect(report.outbreak).to eq('シマオ')
      expect(zebra.reload).to be_sick
    end

    it '1日を締めると、その日200分働いた飼育員の勤務時間がリセットされ保存されること' do
      keeper = build(:keeper).clock_in(200).tap(&:save!)

      service.call

      expect(keeper.reload.remaining_minutes).to eq(480)
    end

    it 'その日に死亡した個体を result.value.casualties で返し、死亡が保存されること' do
      elder = house(build(:animal, species: SpeciesCatalog.grevys_zebra, name: '老', age_in_days: 1_000_000))

      expect(service.call.value.casualties.map(&:name)).to eq(['老'])
      expect(elder.reload).to be_dead
    end

    it '2日目の運営記録の来園者数・収入は前日の累計からの増分(来園12人・¥24,000)になること' do
      service.call
      second = service.call.value

      expect(second.day).to eq(2)
      expect(second.total_visitors).to eq(second.visitors + 12)
      expect(Operating.order(:day).map(&:day)).to eq([1, 2])
    end
  end
end
