# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operating do
  subject(:operating) do
    build(:operating, day:, visitors: 10, income: Money.yen(income), cost: Money.yen(cost), expenses:)
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

    it '収入¥20,000・費用¥8,000・飼料費1件が、再読込後も同じであること' do
      expect(restored.income).to eq(Money.yen(20_000))
      expect(restored.cost).to eq(Money.yen(8_000))
      expect(restored.expenses).to eq([feed])
    end
  end
end
