# frozen_string_literal: true

require 'graphql'

module Zoo
  module Presentation
    module Graphql
      module Types
        class BaseObject < GraphQL::Schema::Object
          private

          def container
            context[:container]
          end

          def occupancy_of(enclosure)
            container.housings.all_occupancies.find { |occupancy| occupancy.enclosure == enclosure } ||
              Domain::Occupancy.new(housings: [], enclosure:)
          end
        end
      end
    end
  end
end
