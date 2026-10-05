# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Zoo < BaseObject
          field :name, String, null: false
          field :day, Integer, null: false
          field :balance, Integer, null: false
          field :reputation, Integer, null: false, method: :reputation_score
          field :admission_fee, Integer, null: false
          field :exhibit_condition, Integer, null: false
          field :experience, Integer, null: false
          field :expected_visitors, Integer, null: false
          field :expected_reputation_change, Float, null: false

          def balance
            object.balance.yen
          end

          def admission_fee
            object.admission_fee.yen
          end

          def exhibit_condition
            Domain::ExhibitCondition.new(on_exhibit).score
          end

          def experience
            Domain::Experience.new(on_exhibit:, fee: object.admission_fee).score
          end

          def expected_visitors
            Domain::VisitorAttraction.new(on_exhibit:, zoo: object).expected_visitors
          end

          def expected_reputation_change
            object.reputation.after_day(experience:, exposure: expected_visitors).value - object.reputation.value
          end

          private

          def on_exhibit
            @on_exhibit ||= container.housings.all_occupancies.flat_map(&:to_a)
          end
        end
      end
    end
  end
end
