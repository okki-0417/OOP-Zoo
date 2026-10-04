# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      EnclosureListCommand = Data.define(:enclosures, :housings) do
        def initialize(enclosures: nil, housings: nil)
          super
        end

        def bind(enclosures:, housings:, **)
          with(enclosures:, housings:)
        end
      end
    end
  end
end
