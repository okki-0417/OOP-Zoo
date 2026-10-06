# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AcquireAnimalCommand = Data.define(
        :species_code, :name, :sex, :max_health, :age_in_days,
        :animals, :species, :zoo, :unit_of_work
      ) do
        def initialize(species_code:, name:, sex:, max_health: 100, age_in_days: 0, animals: nil, species: nil,
                       zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'species_code は必須です' if species_code.nil?
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'sex は必須です' if sex.nil?

          super
        end

        def bind(animals:, species:, zoo:, unit_of_work:, **)
          with(animals:, species:, zoo:, unit_of_work:)
        end
      end
    end
  end
end
