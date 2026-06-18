# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListSpecies < Action
        def call(_params)
          catalog = Domain::SpeciesCatalog
          [200, catalog.keys.map { |key| Serializer.species_ref(key, catalog.find(key)) }]
        end
      end
    end
  end
end
