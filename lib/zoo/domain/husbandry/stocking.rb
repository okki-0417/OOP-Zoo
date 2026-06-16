# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      module Stocking
        module_function

        def required_area(enclosure)
          enclosure.occupants.sum { |animal| animal.species.space_requirement_sqm }
        end

        def overcrowded?(enclosure)
          required_area(enclosure) > enclosure.area_sqm
        end
      end
    end
  end
end
