# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      PopulationCommand = Data.define(:housings) do
        def initialize(housings: nil)
          super
        end

        def bind(housings:, **)
          with(housings:)
        end
      end
    end
  end
end
