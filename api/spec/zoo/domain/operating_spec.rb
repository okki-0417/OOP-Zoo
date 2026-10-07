# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Operating do
      def operating(income:, cost:, visitors: 10, day: 1, expenses: [])
        described_class.new(
          day: day, visitors: visitors,
          income: Shared::Money.yen(income), cost: Shared::Money.yen(cost), expenses: expenses,
          deaths: 0, balance: Shared::Balance.new(100_000),
          reputation: 50, outbreak: nil,
          total_visitors: visitors, total_revenue: Shared::Money.yen(income)
        )
      end

      describe '#net_income' do
        it '収入から費用を引いた純益を返すこと(¥20,000 - ¥8,000 = ¥12,000)' do
          expect(operating(income: 20_000, cost: 8_000).net_income).to eq(Shared::Balance.new(12_000))
        end

        it '費用が収入を上回れば純益は負(赤字)になること' do
          expect(operating(income: 3_000, cost: 8_000).net_income).to eq(Shared::Balance.new(-5_000))
        end
      end

      describe '#to_s' do
        it '日・来園者数・純益を含むこと' do
          expect(operating(income: 20_000, cost: 8_000).to_s).to include('1日目', '来園10人')
        end
      end

      describe '保存と再読込' do
        it '収入¥20,000・費用¥8,000・飼料費1件で保存すると、再読込後も金額と費目が同じであること' do
          feed = Operating::Expense.new(
            category: Operating::Expense::Category.feed, subject: 'ライオン', quantity: 2, amount: Shared::Money.yen(3_000)
          )
          saved = operating(income: 20_000, cost: 8_000, expenses: [feed]).tap(&:save!)
          restored = described_class.find(saved.id)

          expect(restored.income).to eq(Shared::Money.yen(20_000))
          expect(restored.cost).to eq(Shared::Money.yen(8_000))
          expect(restored.balance).to eq(Shared::Balance.new(100_000))
          expect(restored.expenses).to eq([feed])
        end
      end

      describe '.latest' do
        it '1日目と2日目の記録があれば2日目を返すこと' do
          operating(income: 0, cost: 0, day: 1).save!
          second = operating(income: 0, cost: 0, day: 2).tap(&:save!)
          expect(described_class.latest).to eq(second)
        end
      end

      describe '.none_yet' do
        it '累計来園者0人・累計収入¥0の記録を返すこと' do
          expect(described_class.none_yet).to have_attributes(total_visitors: 0, total_revenue: Shared::Money.zero)
        end
      end
    end
  end
end
