# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Zoo do
  subject(:zoo) { build(:zoo, name: 'おうきの動物園', admission_fee: Money.yen(2_000), funds:) }

  let(:funds) { Money.zero }

  describe '#day' do
    context '作った直後のとき' do
      it '0 を返すこと' do
        expect(zoo.day).to eq(0)
      end
    end

    context '2日営業したとき' do
      before { 2.times { |elapsed| zoo.operatings.build(day: elapsed + 1) } }

      it '営業の件数 2 を返すこと' do
        expect(zoo.day).to eq(2)
      end
    end
  end

  describe '#season' do
    context '0日目のとき' do
      it '春を返すこと' do
        expect(zoo.season.label).to eq('春')
      end
    end

    context '101日目のとき' do
      before { 101.times { |elapsed| zoo.operatings.build(day: elapsed + 1) } }

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

  describe '.of' do
    subject(:owned) { described_class.of(user) }

    let(:user) { create(:user) }

    before { create(:zoo, name: 'よその園') }

    context 'ユーザーがまだ動物園を持っていないとき' do
      it '既定(OOP動物園・入園料¥2,000・資金¥1,000,000)でそのユーザーの動物園を保存して返すこと' do
        expect(owned).to be_persisted
        expect(owned).to have_attributes(user:, name: 'OOP動物園', admission_fee: Money.yen(2_000))
        expect(owned.balance).to eq(Balance.new(1_000_000))
      end
    end

    context 'ユーザーがすでに動物園を持っているとき' do
      let!(:existing) { create(:zoo, name: '既存園', user:) }

      it 'その動物園を返すこと' do
        expect(owned).to eq(existing)
      end
    end
  end

  describe '#save!' do
    subject(:restored) { described_class.find(zoo.id) }

    before do
      zoo.gain_reputation(10)
      zoo.save!
    end

    it '評判+10を保存すると、再読込後も評判60であること' do
      expect(restored.reputation_score).to eq(60)
    end
  end

  describe '#to_s' do
    it '園名 "おうきの動物園" を返すこと' do
      expect(zoo.to_s).to eq('おうきの動物園')
    end
  end
end
