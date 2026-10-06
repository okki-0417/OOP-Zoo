# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      TransferAnimalCommand = Data.define(:animal_id, :enclosure_id, :enclosures, :animals, :housings, :unit_of_work) do
        def initialize(animal_id:, enclosure_id:, enclosures: nil, animals: nil, housings: nil, unit_of_work: nil)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end

        def bind(enclosures:, animals:, housings:, unit_of_work:, **)
          with(enclosures:, animals:, housings:, unit_of_work:)
        end
      end
    end
  end
end
