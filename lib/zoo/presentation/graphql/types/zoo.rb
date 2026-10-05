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

          def balance
            object.balance.yen
          end

          def admission_fee
            object.admission_fee.yen
          end
        end
      end
    end
  end
end
