# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class Population
        def initialize(enclosures:)
          @enclosures = enclosures
        end

        def call
          @enclosures.all.sum(&:population)
        end
      end
    end
  end
end
