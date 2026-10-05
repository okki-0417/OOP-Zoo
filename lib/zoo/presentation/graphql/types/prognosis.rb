# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Prognosis < BaseObject
          field :outlook, Outlook, null: false
          field :days_to_death, Integer
          field :cause_of_death, String, method: :cause_of_death_label
        end
      end
    end
  end
end
