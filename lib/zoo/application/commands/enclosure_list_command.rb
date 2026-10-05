# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      EnclosureListCommand = Data.define(:enclosures, :housings, :assignments) do
        def initialize(enclosures: nil, housings: nil, assignments: nil)
          super
        end

        def bind(enclosures:, housings:, assignments:, **)
          with(enclosures:, housings:, assignments:)
        end
      end
    end
  end
end
