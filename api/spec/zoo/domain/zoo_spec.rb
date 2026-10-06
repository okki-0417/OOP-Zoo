# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Zoo do
  S = Zoo::Domain::Shared
  T = Zoo::Domain
  H = Zoo::Domain

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

  describe '構成要素の参照' do
    it 'enclosures / keepers / veterinarians は登録したものを返し、複製であること' do
      area = zoo.add_enclosure(savanna)
      keeper = zoo.hire_keeper(Zoo::Domain::Keeper.new(name: '田中', specialties: [T::TaxonClass.mammal]))
      vet = zoo.hire_veterinarian(Zoo::Domain::Veterinarian.new(name: '佐藤'))

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
    it '園名(エリア数)の形で表されること' do
      zoo.add_enclosure(savanna)
      expect(zoo.to_s).to eq('おうきの動物園(1エリア)')
    end
  end
end
