# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Operating do
  let(:feed) do
    Operating::Expense.new(category: Operating::Expense::Category.feed, subject: 'ライオン', quantity: 3,
                           amount: Money.yen(4_500))
  end
  let(:operating) do
    create(:operating, visitors: 12, income: Money.yen(24_000), cost: Money.yen(4_500),
                       expenses: [feed])
  end

  describe 'income' do
    it '¥24,000 を円の整数 24000 で返すこと' do
      expect(run_graphql_field('Operating.income', operating)).to eq(24_000)
    end
  end

  describe 'cost' do
    it '¥4,500 を円の整数 4500 で返すこと' do
      expect(run_graphql_field('Operating.cost', operating)).to eq(4_500)
    end
  end

  describe 'netIncome' do
    it '収入 ¥24,000 − 費用 ¥4,500 を円の整数 19500 で返すこと' do
      expect(run_graphql_field('Operating.netIncome', operating)).to eq(19_500)
    end
  end

  describe 'balance' do
    it '開業資金 ¥100,000 にその日の純益 ¥19,500 を足した円の整数 119500 で返すこと' do
      expect(run_graphql_field('Operating.balance', operating)).to eq(119_500)
    end
  end

  describe 'expenses' do
    it '保存した内訳(飼料費 ライオン×3 ¥4,500)を再読込後も返すこと' do
      expect(run_graphql_field('Operating.expenses', Operating.find(operating.id))).to eq([feed])
    end
  end
end
