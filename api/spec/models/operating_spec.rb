# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operating do
  subject(:operating) do
    described_class.new(
      day:, visitors: 10, income: Money.yen(income), cost: Money.yen(cost), expenses:,
      deaths: 0, balance: Balance.new(100_000), reputation: 50, outbreak: nil,
      total_visitors: 10, total_revenue: Money.yen(income)
    )
  end

  let(:day) { 1 }
  let(:income) { 20_000 }
  let(:cost) { 8_000 }
  let(:expenses) { [] }

  describe '#net_income' do
    context '収入 ¥20,000・費用 ¥8,000 のとき' do
      it 'Balance(12,000) を返すこと' do
        expect(operating.net_income).to eq(Balance.new(12_000))
      end
    end

    context '費用 ¥8,000 が収入 ¥3,000 を上回るとき' do
      let(:income) { 3_000 }

      it '負の Balance(-5,000) を返すこと' do
        expect(operating.net_income).to eq(Balance.new(-5_000))
      end
    end
  end

  describe '#to_s' do
    it '"1日目" と "来園10人" を含むこと' do
      expect(operating.to_s).to include('1日目', '来園10人')
    end
  end

  describe '#save!' do
    subject(:restored) { described_class.find(operating.id) }

    let(:feed) do
      Operating::Expense.new(
        category: Operating::Expense::Category.feed, subject: 'ライオン', quantity: 2, amount: Money.yen(3_000)
      )
    end
    let(:expenses) { [feed] }

    before { operating.save! }

    it '収入¥20,000・費用¥8,000・残高¥100,000・飼料費1件が、再読込後も同じであること' do
      expect(restored.income).to eq(Money.yen(20_000))
      expect(restored.cost).to eq(Money.yen(8_000))
      expect(restored.balance).to eq(Balance.new(100_000))
      expect(restored.expenses).to eq([feed])
    end
  end

  describe '.latest' do
    context '1日目と2日目の記録があるとき' do
      let(:day) { 2 }

      before do
        operating.dup.tap { |first| first.day = 1 }.save!
        operating.save!
      end

      it '2日目の記録を返すこと' do
        expect(described_class.latest).to eq(operating)
      end
    end
  end

  describe '.none_yet' do
    it '累計来園者 0人・累計収入 ¥0 の記録を返すこと' do
      expect(described_class.none_yet).to have_attributes(total_visitors: 0, total_revenue: Money.zero)
    end
  end
end
