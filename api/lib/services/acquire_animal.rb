# frozen_string_literal: true

module Services
  class AcquireAnimal
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:acquire_animal) do
        species = ::SpeciesCatalog.find(@command.species_code) or
          raise Errors::SpeciesNotFound, "未知の種です: #{@command.species_code}"

        ApplicationRecord.transaction do
          animal = ::Animal.new(
            species: species,
            name: @command.name,
            sex: ::Animal::Sex.new(@command.sex),
            max_health: @command.max_health,
            age_in_days: @command.age_in_days
          )

          zoo = ::Zoo.current

          ::Acquiring.new(zoo:, animal:).settle

          zoo.save!
          animal.save!

          animal
        end
      end
    end
  end
end
