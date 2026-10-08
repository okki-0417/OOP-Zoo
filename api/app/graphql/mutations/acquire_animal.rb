# frozen_string_literal: true

module Mutations
  class AcquireAnimal < BaseMutation
    type Types::Animal, null: false

    argument :species_code, String
    argument :name, String
    argument :sex, Types::Sex

    def resolve(species_code:, name:, sex:)
      animal = Animal.new(
        species: SpeciesCatalog.find!(species_code), name:, sex: Animal::Sex.new(sex),
        max_health: Acquiring::ACQUIRED_HEALTH
      )
      Acquiring.new(zoo: Zoo.current, animal:).perform
    end
  end
end
