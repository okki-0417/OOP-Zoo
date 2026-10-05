# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      HouseAnimalCommand = Data.define(
        :enclosure_id, :animal_id, :enclosures, :animals, :housings, :assignments, :unit_of_work
      ) do
        def initialize(enclosure_id:, animal_id:, enclosures: nil, animals: nil, housings: nil, assignments: nil,
                       unit_of_work: nil)
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super
        end

        def bind(enclosures:, animals:, housings:, assignments:, unit_of_work:, **)
          with(enclosures:, animals:, housings:, assignments:, unit_of_work:)
        end
      end
    end
  end
end
