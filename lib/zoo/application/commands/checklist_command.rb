# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      ChecklistCommand = Data.define(:animals, :housings) do
        def initialize(animals: nil, housings: nil)
          super
        end

        def bind(animals:, housings:, **)
          with(animals:, housings:)
        end
      end
    end
  end
end
