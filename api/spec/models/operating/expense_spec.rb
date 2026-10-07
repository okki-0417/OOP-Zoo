# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operating::Expense do
  def feed(subject: 'ライオン', quantity: 3, amount: 4_500)
    described_class.new(category: Operating::Expense::Category.feed, subject:, quantity:,
                        amount: Money.yen(amount))
  end

  describe '.new' do
    it 'quantity を省略すると1になること' do
      expense = described_class.new(category: Operating::Expense::Category.upkeep, subject: 'サバンナ',
                                    amount: Money.yen(5_000))
      expect(expense.quantity).to eq(1)
    end

    it 'subject が空文字なら ArgumentError になること' do
      expect { feed(subject: '') }.to raise_error(ArgumentError, /対象は必須/)
    end

    it 'quantity が0なら ArgumentError になること' do
      expect { feed(quantity: 0) }.to raise_error(ArgumentError, /数量/)
    end

    it 'quantity が整数でない(1.5)なら ArgumentError になること' do
      expect { feed(quantity: 1.5) }.to raise_error(ArgumentError, /数量/)
    end

    it '凍結されていること' do
      expect(feed).to be_frozen
    end
  end

  describe '#==' do
    it '費目・対象・数量・金額が同じなら等価であること' do
      expect(feed).to eq(feed)
    end

    it '数量が違えば等価でないこと(3頭と2頭)' do
      expect(feed(quantity: 3)).not_to eq(feed(quantity: 2))
    end
  end

  describe '#to_s' do
    it '数量が2以上なら「費目 対象×数量 金額」になること' do
      expect(feed.to_s).to eq('飼料費 ライオン×3 ¥4,500')
    end

    it '数量が1なら数量を省くこと' do
      expect(feed(quantity: 1, amount: 1_500).to_s).to eq('飼料費 ライオン ¥1,500')
    end
  end
end

RSpec.describe Operating::Expense::Category do
  describe '.payroll / .upkeep / .feed' do
    it 'それぞれ人件費・施設維持費・飼料費のラベルを持つこと' do
      expect([described_class.payroll, described_class.upkeep, described_class.feed].map(&:label))
        .to eq(%w[人件費 施設維持費 飼料費])
    end
  end

  describe '.new' do
    it '文字列 "feed" からも作れ、.feed と等価であること' do
      expect(described_class.new('feed')).to eq(described_class.feed)
    end

    it '未知の費目なら InvalidValue になること' do
      expect { described_class.new(:tax) }.to raise_error(Errors::InvalidValue, /未知の費目/)
    end
  end

  describe '#to_s' do
    it 'ラベルを返すこと' do
      expect(described_class.payroll.to_s).to eq('人件費')
    end
  end
end
