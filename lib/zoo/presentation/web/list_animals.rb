# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListAnimals < Action
        def call(_params)
          [200, @container.animal_list.call.map(&:to_h)]
        end
      end
    end
  end
end
