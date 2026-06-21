# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class Population
        def initialize(housings:)
          @housings = housings
        end

        def call
          Domain::Occupancy.new(@housings.all).all_occupants.size
        end
      end
    end
  end
end
