# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Zoo do
  S = Zoo::Domain::Shared
  T = Zoo::Domain::Taxonomy
  H = Zoo::Domain::Husbandry

  def savanna
    H::Enclosure.new(name: 'サバンナ', temperature: S::Temperature.celsius(30), capacity: 5)
  end

  let(:zoo) do
    described_class.new(name: 'おうきの動物園', admission_fee: S::Money.yen(2000))
  end

  describe '経過日数と季節' do
    it '生成直後は0日目で春であること' do
      expect(zoo.day).to eq(0)
      expect(zoo.season.label).to eq('春')
    end

    it '日を進めると経過日数が増え、やがて季節が変わること' do
      expect { zoo.advance_day }.to change(zoo, :day).by(1)
      100.times { zoo.advance_day }
      expect(zoo.season.label).to eq('夏')
    end
  end

  describe '残高と支出' do
    it '来園者を受け入れると収益ぶん残高が増えること(2000円×100=¥200,000)' do
      zoo.admit_visitors(100)

      expect(zoo.balance).to eq(S::Balance.new(200_000))
    end

    it '残高を超えて支出すると赤字になり bankrupt? が true を返すこと' do
      zoo.admit_visitors(1)
      zoo.spend(S::Money.yen(5_000))

      expect(zoo.bankrupt?).to be(true)
    end

    it '初期資金を与えると残高の初期値になること' do
      funded = described_class.new(name: 'おうきの動物園', admission_fee: S::Money.yen(2000), funds: S::Money.yen(50_000))

      expect(funded.balance).to eq(S::Balance.new(50_000))
    end
  end

  describe '#afford? / #purchase' do
    let(:funded) do
      described_class.new(name: 'おうきの動物園', admission_fee: S::Money.yen(2000), funds: S::Money.yen(30_000))
    end

    it '残高ちょうどの額は支払えると判定すること' do
      expect(funded.afford?(S::Money.yen(30_000))).to be(true)
      expect(funded.afford?(S::Money.yen(30_001))).to be(false)
    end

    it 'purchase は費用ぶん残高を減らして新しい残高を返すこと' do
      expect(funded.purchase(S::Money.yen(12_000))).to eq(S::Balance.new(18_000))
    end

    it '残高を超える purchase は InsufficientFunds を送出し残高を変えないこと' do
      expect { funded.purchase(S::Money.yen(40_000)) }.to raise_error(Zoo::Domain::Errors::InsufficientFunds)
      expect(funded.balance).to eq(S::Balance.new(30_000))
    end
  end

  describe '入園料と収益' do
    it '来園者数に応じて収益が積み上がること' do
      zoo.admit_visitors(100)
      zoo.admit_visitors(50)
      expect(zoo.visitor_count).to eq(150)
      expect(zoo.revenue).to eq(S::Money.yen(300_000))
    end

    it 'admit_visitors はその回の収入(料金×人数)を返すこと(累計ではない)' do
      zoo.admit_visitors(100)
      expect(zoo.admit_visitors(50)).to eq(S::Money.yen(100_000))
    end
  end

  describe '収容' do
    it '本園のエリアにのみ収容できること' do
      area = zoo.add_enclosure(savanna)
      zoo.house(build_adult(T::SpeciesCatalog.grevys_zebra), area)
      expect(zoo.population).to eq(1)
    end

    it '本園に属さないエリアには収容できないこと' do
      foreign = savanna
      expect { zoo.house(build_adult(T::SpeciesCatalog.grevys_zebra), foreign) }
        .to raise_error(ArgumentError)
    end
  end

  describe '保全への貢献' do
    it '展示中の絶滅危惧種を集計できること' do
      area = zoo.add_enclosure(savanna)
      zoo.house(build_adult(T::SpeciesCatalog.grevys_zebra), area)
      zoo.house(build_adult(T::SpeciesCatalog.reticulated_giraffe), area)
      expect(zoo.threatened_species.size).to eq(2)
    end
  end

  describe '日次運営とライフサイクル' do
    it '寿命を迎えた個体は死亡し、慰霊記録とイベントに残ること' do
      pond = zoo.add_enclosure(
        H::Enclosure.new(name: '錦鯉の池', temperature: S::Temperature.celsius(20), capacity: 3)
      )
      koi_species = T::SpeciesCatalog.koi
      old_koi = build_animal(koi_species, name: '長老', age_in_days: koi_species.lifespan_years * 365)
      zoo.house(old_koi, pond)

      dead = zoo.open_for_a_day

      expect(dead).to include(old_koi)
      expect(zoo.deceased).to include(old_koi)
      expect(zoo.population).to eq(0)
      events = zoo.pull_events
      expect(events.map(&:class)).to include(Zoo::Domain::Events::AnimalDied)
      expect(events.first.cause).to eq(:old_age)
    end
  end

  describe '構成要素の参照' do
    it 'enclosures / keepers / veterinarians は登録したものを返し、複製であること' do
      area = zoo.add_enclosure(savanna)
      keeper = zoo.hire_keeper(Zoo::Domain::Staff::Keeper.new(name: '田中', specialties: [T::TaxonClass.mammal]))
      vet = zoo.hire_veterinarian(Zoo::Domain::Staff::Veterinarian.new(name: '佐藤'))

      expect(zoo.enclosures).to contain_exactly(area)
      expect(zoo.keepers).to contain_exactly(keeper)
      expect(zoo.veterinarians).to contain_exactly(vet)

      zoo.enclosures.clear
      expect(zoo.enclosures).to contain_exactly(area)
    end

    it 'find_enclosure は名前でエリアを引き、未知の名前には nil を返すこと' do
      area = zoo.add_enclosure(savanna)
      expect(zoo.find_enclosure('サバンナ')).to eq(area)
      expect(zoo.find_enclosure('存在しない')).to be_nil
    end
  end

  describe '#to_s' do
    it '園名(エリア数・頭数)の形で表されること' do
      zoo.add_enclosure(savanna)
      zoo.house(build_adult(T::SpeciesCatalog.lion), zoo.find_enclosure('サバンナ'))
      expect(zoo.to_s).to eq('おうきの動物園(1エリア・1頭)')
    end
  end
end
