# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Operating do
      def build(income:, cost:)
        described_class.new(
          day: 1, visitors: 10, income: Shared::Money.yen(income), cost: Shared::Money.yen(cost),
          deaths: 0, balance: Shared::Balance.new(100_000), reputation: 50
        )
      end

      describe '#net_income' do
        it '収入から費用を引いた純益を返すこと(¥20,000 - ¥8,000 = ¥12,000)' do
          expect(build(income: 20_000, cost: 8_000).net_income).to eq(Shared::Balance.new(12_000))
        end

        it '費用が収入を上回れば純益は負(赤字)になること' do
          expect(build(income: 3_000, cost: 8_000).net_income).to eq(Shared::Balance.new(-5_000))
        end
      end

      describe '#to_s' do
        it '日・来園者数・純益を含むこと' do
          expect(build(income: 20_000, cost: 8_000).to_s).to include('1日目', '来園10人')
        end
      end
    end
  end
end
