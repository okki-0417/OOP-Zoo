# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Operating do
      def reconstituted(income:, cost:, visitors: 10, day: 1)
        described_class.reconstitute(
          id: Shared::Identifier.new,
          day: day, visitors: visitors,
          income: Shared::Money.yen(income), cost: Shared::Money.yen(cost),
          deaths: 0, balance: Shared::Balance.new(100_000),
          reputation: 50, outbreak: nil,
          total_visitors: visitors, total_revenue: Shared::Money.yen(income)
        )
      end

      describe '#net_income' do
        it '収入から費用を引いた純益を返すこと(¥20,000 - ¥8,000 = ¥12,000)' do
          expect(reconstituted(income: 20_000, cost: 8_000).net_income).to eq(Shared::Balance.new(12_000))
        end

        it '費用が収入を上回れば純益は負(赤字)になること' do
          expect(reconstituted(income: 3_000, cost: 8_000).net_income).to eq(Shared::Balance.new(-5_000))
        end
      end

      describe '#to_s' do
        it '日・来園者数・純益を含むこと' do
          expect(reconstituted(income: 20_000, cost: 8_000).to_s).to include('1日目', '来園10人')
        end
      end
    end
  end
end
