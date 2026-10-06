# frozen_string_literal: true

module Zoo
  module Domain
    class OperatingCost
      Expense = Operating::Expense

      def initialize(enclosures:, staff:, species:)
        @enclosures = enclosures
        @staff = staff
        @species = species
      end

      def amount
        expenses.sum(Shared::Money.zero, &:amount)
      end

      def expenses
        payroll + upkeep + feed
      end

      private

      def payroll
        @staff.map do |member|
          Expense.new(category: Expense::Category.payroll, subject: "#{member.job_title} #{member.name}",
                      amount: member.salary)
        end
      end

      def upkeep
        @enclosures.map do |enclosure|
          Expense.new(category: Expense::Category.upkeep, subject: enclosure.name, amount: enclosure.daily_upkeep)
        end
      end

      def feed
        @species.tally.map do |species, heads|
          Expense.new(category: Expense::Category.feed, subject: species.name_ja, quantity: heads,
                      amount: species.daily_food_cost * heads)
        end
      end
    end
  end
end
