# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      HouseAnimalCommand = Data.define(:enclosure_id, :animal_id) do
        def initialize(enclosure_id:, animal_id:)
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super
        end
      end
    end
  end
end
