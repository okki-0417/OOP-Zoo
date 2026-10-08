# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Zoo do
  subject(:zoo) { create(:zoo, name: 'おうきの動物園', admission_fee: Money.yen(2_000), opening_funds:) }

  let(:opening_funds) { Money.zero }

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
    let(:opening_funds) { Money.yen(100_000) }

    context '開業資金 ¥100,000 で何もしていないとき' do
      it 'Balance(100,000) を返すこと' do
        expect(zoo.balance).to eq(Balance.new(100_000))
      end
    end

    context '収入 ¥30,000・費用 ¥10,000 の営業日と、¥5,000 の建設があるとき' do
      before do
        create(:operating, zoo:, income: Money.yen(30_000), cost: Money.yen(10_000))
        create(:constructing, zoo:, cost: Money.yen(5_000))
      end

      it '開業資金に営業の純益を足し建設費を引いた Balance(115,000) を返すこと' do
        expect(zoo.balance).to eq(Balance.new(115_000))
      end
    end

    context '¥3,000 の購入と ¥2,000 の雇用があるとき' do
      before do
        create(:acquiring, zoo:, cost: Money.yen(3_000))
        create(:hiring, zoo:, cost: Money.yen(2_000))
      end

      it 'Balance(95,000) を返すこと' do
        expect(zoo.balance).to eq(Balance.new(95_000))
      end
    end
  end

  describe '#closing_balance' do
    let(:opening_funds) { Money.yen(100_000) }

    before do
      create(:operating, zoo:, day: 1, income: Money.yen(30_000), cost: Money.yen(10_000))
      create(:constructing, zoo:, day: 1, cost: Money.yen(5_000))
      create(:operating, zoo:, day: 2, income: Money.yen(1_000), cost: Money.yen(0))
    end

    context '1日目の終わりのとき' do
      it '1日目の純益だけを足し、1日目のあとの建設は引かない Balance(120,000) を返すこと' do
        expect(zoo.closing_balance(1)).to eq(Balance.new(120_000))
      end
    end

    context '2日目の終わりのとき' do
      it '2日目までの純益を足し建設費を引いた Balance(116,000) を返すこと' do
        expect(zoo.closing_balance(2)).to eq(Balance.new(116_000))
      end
    end
  end

  describe '#admission_income' do
    context '入園料 ¥2,000 で100人のとき' do
      it 'Money(200,000) を返すこと' do
        expect(zoo.admission_income(100)).to eq(Money.yen(200_000))
      end
    end

    context '来園者数が -1 のとき' do
      it 'ArgumentError を投げること' do
        expect { zoo.admission_income(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#bankrupt?' do
    context '開業資金 ¥2,000 に費用 ¥5,000 の営業日があるとき' do
      let(:opening_funds) { Money.yen(2_000) }

      before { create(:operating, zoo:, cost: Money.yen(5_000)) }

      it 'true を返すこと' do
        expect(zoo.bankrupt?).to be(true)
      end
    end

    context '残高が ¥0 のとき' do
      it 'false を返すこと' do
        expect(zoo.bankrupt?).to be(false)
      end
    end
  end

  describe '#afford?' do
    let(:opening_funds) { Money.yen(30_000) }

    it '残高 ¥30,000 に対し ¥30,000 は true、¥30,001 は false を返すこと' do
      expect(zoo.afford?(Money.yen(30_000))).to be(true)
      expect(zoo.afford?(Money.yen(30_001))).to be(false)
    end
  end

  describe '#authorize_payment' do
    let(:opening_funds) { Money.yen(30_000) }

    context '残高 ¥30,000 以内の ¥12,000 のとき' do
      it '例外を投げないこと' do
        expect { zoo.authorize_payment(Money.yen(12_000)) }.not_to raise_error
      end
    end

    context '残高 ¥30,000 を超える ¥40,000 のとき' do
      it 'InsufficientFunds を投げること' do
        expect { zoo.authorize_payment(Money.yen(40_000)) }.to raise_error(Errors::InsufficientFunds)
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
        expect(owned.opening_funds).to eq(Money.yen(1_000_000))
      end
    end

    context 'ユーザーがすでに動物園を持っているとき' do
      let!(:existing) { create(:zoo, name: '既存園', user:) }

      it 'その動物園を返すこと' do
        expect(owned).to eq(existing)
      end
    end
  end

  describe '#reputation' do
    context 'まだ営業していないとき' do
      it '既定の評判 50 を返すこと' do
        expect(zoo.reputation).to eq(Zoo::Reputation.default)
      end
    end

    context '1日目の評判 55.5・2日目の評判 62.25 で営業したとき' do
      before do
        create(:operating, zoo:, day: 2, reputation: Zoo::Reputation.new(62.25))
        create(:operating, zoo:, day: 1, reputation: Zoo::Reputation.new(55.5))
      end

      it '最新の2日目の評判 62.25 を返すこと' do
        expect(zoo.reputation).to eq(Zoo::Reputation.new(62.25))
      end
    end
  end

  describe '#to_s' do
    it '園名 "おうきの動物園" を返すこと' do
      expect(zoo.to_s).to eq('おうきの動物園')
    end
  end
end
