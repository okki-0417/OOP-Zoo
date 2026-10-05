# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AnimalPrognosisCommand = Data.define(:animal_id, :animals, :housings, :zoo) do
        def initialize(animal_id:, animals: nil, housings: nil, zoo: nil)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super
        end

        def bind(animals:, housings:, zoo:, **)
          with(animals:, housings:, zoo:)
        end
      end
    end
  end
end
