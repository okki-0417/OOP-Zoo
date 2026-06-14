# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListDeceased < Action
        def call(_params)
          [200, @container.deceased_list.call.map { |record| Serializer.deceased(record) }]
        end
      end
    end
  end
end
