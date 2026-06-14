# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListThreatened < Action
        def call(_params)
          [200, @container.threatened_species.call.map { |record| Serializer.exhibited_species(record) }]
        end
      end
    end
  end
end
