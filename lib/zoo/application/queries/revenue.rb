# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class Revenue
        def initialize(zoo:)
          @zoo = zoo
        end

        def call
          @zoo.load.revenue
        end
      end
    end
  end
end
