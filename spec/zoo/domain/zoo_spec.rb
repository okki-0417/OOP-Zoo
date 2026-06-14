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

  describe '残高と支出' do
    it '来園者を受け入れると収益ぶん残高が増えること(2000円×100=¥200,000)' do
      zoo.admit_visitors(100)

      expect(zoo.balance).to eq(S::Balance.new(200_000))
    end

    it '残高を超えて支出すると赤字になり bankrupt? が true を返すこと' do
      zoo.admit_visitors(1) # 残高 2000円
      zoo.spend(S::Money.yen(5_000))

      expect(zoo.bankrupt?).to be(true)
    end

    it '初期資金を与えると残高の初期値になること' do
      funded = described_class.new(name: 'おうきの動物園', admission_fee: S::Money.yen(2000), funds: S::Money.yen(50_000))

      expect(funded.balance).to eq(S::Balance.new(50_000))
    end
  end

  describe '入園料と収益' do
    it '来園者数に応じて収益が積み上がること' do
      zoo.admit_visitors(100)
      zoo.admit_visitors(50)
      expect(zoo.visitor_count).to eq(150)
      expect(zoo.revenue).to eq(S::Money.yen(300_000))
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
      zoo.house(build_adult(T::SpeciesCatalog.grevys_zebra), area)   # EN
      zoo.house(build_adult(T::SpeciesCatalog.reticulated_giraffe), area) # EN
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
end
