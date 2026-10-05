# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class AlertKind < GraphQL::Schema::Enum
          %i[
            insolvent no_keeper no_veterinarian unassigned filthy overcrowded barren
            grave guarded starving hungry sick malnourished stressed climate due unhoused
          ].each { |kind| value kind.to_s.upcase, value: kind }
        end
      end
    end
  end
end
