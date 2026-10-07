# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Expense do
  let(:expense) do
    Operating::Expense.new(category: Operating::Expense::Category.feed, subject: 'ライオン', quantity: 3,
                           amount: Money.yen(4_500))
  end

  describe 'category' do
    it '飼料費で :feed(ExpenseCategory の FEED)を返すこと' do
      category = run_graphql_field('Expense.category', expense)

      expect(category).to eq(:feed)
      expect(Types::ExpenseCategory.coerce_isolated_result(category)).to eq('FEED')
    end
  end

  describe 'subject' do
    it '"ライオン" を返すこと' do
      expect(run_graphql_field('Expense.subject', expense)).to eq('ライオン')
    end
  end

  describe 'quantity' do
    it '3 を返すこと' do
      expect(run_graphql_field('Expense.quantity', expense)).to eq(3)
    end
  end

  describe 'amount' do
    it '¥4,500 を円の整数 4500 で返すこと' do
      expect(run_graphql_field('Expense.amount', expense)).to eq(4_500)
    end
  end
end
