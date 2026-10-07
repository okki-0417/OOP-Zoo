# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo do
  subject(:zoo) { build(:zoo, name: 'おうきの動物園', admission_fee: Money.yen(2_000), funds:) }

  let(:funds) { Money.zero }

  describe '#day' do
    it '作った直後は 0 を返すこと' do
      expect(zoo.day).to eq(0)
    end
  end

  describe '#advance_day' do
    it 'day を 1 進めること' do
      expect { zoo.advance_day }.to change(zoo, :day).by(1)
    end
  end

  describe '#season' do
    context '0日目のとき' do
      it '春を返すこと' do
        expect(zoo.season.label).to eq('春')
      end
    end

    context '101日目のとき' do
      before { 101.times { zoo.advance_day } }

      it '夏を返すこと' do
        expect(zoo.season.label).to eq('夏')
      end
    end
  end

  describe '#balance' do
    context '資金 ¥50,000 で作ったとき' do
      let(:funds) { Money.yen(50_000) }

      it 'Balance(50,000) を返すこと' do
        expect(zoo.balance).to eq(Balance.new(50_000))
      end
    end
  end

  describe '#admit_visitors' do
    it '入園料 ¥2,000 × 100人 = ¥200,000 だけ残高を増やすこと' do
      zoo.admit_visitors(100)

      expect(zoo.balance).to eq(Balance.new(200_000))
    end

    context 'すでに100人を受け入れているとき' do
      before { zoo.admit_visitors(100) }

      it '50人を受け入れると、その回の収入 ¥100,000 を返すこと' do
        expect(zoo.admit_visitors(50)).to eq(Money.yen(100_000))
      end

      it '50人を受け入れると、累計の visitor_count が 150・revenue が ¥300,000 になること' do
        zoo.admit_visitors(50)

        expect(zoo.visitor_count).to eq(150)
        expect(zoo.revenue).to eq(Money.yen(300_000))
      end
    end
  end

  describe '#bankrupt?' do
    context '残高 ¥2,000 から ¥5,000 を spend したとき' do
      before do
        zoo.admit_visitors(1)
        zoo.spend(Money.yen(5_000))
      end

      it 'true を返すこと' do
        expect(zoo.bankrupt?).to be(true)
      end
    end
  end

  describe '#afford?' do
    let(:funds) { Money.yen(30_000) }

    it '残高 ¥30,000 に対し ¥30,000 は true、¥30,001 は false を返すこと' do
      expect(zoo.afford?(Money.yen(30_000))).to be(true)
      expect(zoo.afford?(Money.yen(30_001))).to be(false)
    end
  end

  describe '#purchase' do
    let(:funds) { Money.yen(30_000) }

    context '残高 ¥30,000 以内の ¥12,000 のとき' do
      it '残高を減らして Balance(18,000) を返すこと' do
        expect(zoo.purchase(Money.yen(12_000))).to eq(Balance.new(18_000))
      end
    end

    context '残高 ¥30,000 を超える ¥40,000 のとき' do
      it 'InsufficientFunds を投げ、残高を Balance(30,000) のままにすること' do
        expect { zoo.purchase(Money.yen(40_000)) }.to raise_error(Errors::InsufficientFunds)
        expect(zoo.balance).to eq(Balance.new(30_000))
      end
    end
  end

  describe '#valid?' do
    context '園名が空のとき' do
      subject(:zoo) { build(:zoo, name: '') }

      it 'false を返すこと' do
        expect(zoo).not_to be_valid
      end
    end
  end

  describe '.current' do
    subject(:current) { described_class.current }

    context '動物園がまだないとき' do
      it '既定(OOP動物園・入園料¥2,000・資金¥1,000,000)で保存した動物園を返すこと' do
        expect(current).to be_persisted
        expect(current).to have_attributes(name: 'OOP動物園', admission_fee: Money.yen(2_000))
        expect(current.balance).to eq(Balance.new(1_000_000))
      end
    end

    context '動物園がすでにあるとき' do
      let!(:existing) { create(:zoo, name: '既存園') }

      it 'その動物園を返すこと' do
        expect(current).to eq(existing)
      end
    end
  end

  describe '#save!' do
    subject(:restored) { described_class.find(zoo.id) }

    before do
      zoo.gain_reputation(10).admit_visitors(50)
      zoo.save!
    end

    it '評判+10・来園者50人を保存すると、再読込後も評判60・収入¥100,000・来園者50人であること' do
      expect(restored.reputation_score).to eq(60)
      expect(restored.revenue).to eq(Money.yen(100_000))
      expect(restored.visitor_count).to eq(50)
    end
  end

  describe '#to_s' do
    it '園名 "おうきの動物園" を返すこと' do
      expect(zoo.to_s).to eq('おうきの動物園')
    end
  end
end
