# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListVeterinarians < Action
        def call(_params)
          [200, @container.veterinarian_list.call.map { |vet| Serializer.veterinarian(vet) }]
        end
      end
    end
  end
end
