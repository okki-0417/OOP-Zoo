# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListEnclosures < Action
        def call(_params)
          [200, @container.enclosure_list.call.map { |enclosure| Serializer.enclosure_summary(enclosure) }]
        end
      end
    end
  end
end
