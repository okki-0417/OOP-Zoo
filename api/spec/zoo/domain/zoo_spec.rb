# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Zoo do
  S = Zoo::Domain::Shared

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

  describe '妥当性' do
    it '園名が空の動物園は無効であること' do
      expect(described_class.new(name: '', admission_fee: S::Money.yen(2000))).not_to be_valid
    end
  end

  describe '.current' do
    it '動物園がまだ無ければ既定(OOP動物園・入園料¥2,000・資金¥1,000,000)で作ること' do
      zoo = described_class.current
      expect(zoo).to be_persisted
      expect(zoo).to have_attributes(name: 'OOP動物園', admission_fee: S::Money.yen(2000))
      expect(zoo.balance).to eq(S::Balance.new(1_000_000))
    end

    it '既にあればその動物園を返すこと' do
      existing = described_class.create!(name: '既存園', admission_fee: S::Money.yen(500))
      expect(described_class.current).to eq(existing)
    end
  end

  describe '保存と再読込' do
    it '評判を+10・来園者50人を入れて保存すると、再読込後も評判60・収入¥100,000であること' do
      zoo.gain_reputation(10).admit_visitors(50)
      zoo.save!
      restored = described_class.find(zoo.id)
      expect(restored.reputation_score).to eq(60)
      expect(restored.revenue).to eq(S::Money.yen(100_000))
      expect(restored.visitor_count).to eq(50)
    end
  end

  describe '#to_s' do
    it '園名で表されること' do
      expect(zoo.to_s).to eq('おうきの動物園')
    end
  end
end
