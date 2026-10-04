# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      SpeciesListCommand = Data.define(:species) do
        def initialize(species: nil)
          super
        end

        def bind(species:, **)
          with(species:)
        end
      end
    end
  end
end
