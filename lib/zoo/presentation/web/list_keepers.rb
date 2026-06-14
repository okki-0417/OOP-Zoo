# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListKeepers < Action
        def call(_params)
          [200, @container.keeper_list.call.map { |keeper| Serializer.keeper(keeper) }]
        end
      end
    end
  end
end
