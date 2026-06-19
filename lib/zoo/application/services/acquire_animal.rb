# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AcquireAnimal
        CONSERVATION_REPUTATION_GAIN = 5

        def initialize(animals:, zoo:, unit_of_work:)
          @animals = animals
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            animal = Domain::Animal.new(
              species: command.species,
              name: command.name,
              sex: command.sex,
              max_health: command.max_health,
              age_in_days: command.age_in_days
            )

            acquire(command.species)
            @animals.save(animal)
            animal
          end
        end

        private

        def acquire(species)
          zoo = @zoo.load
          if species.tradeable?
            zoo.purchase(Domain::Pricing.acquisition_price(species))
          else
            zoo.gain_reputation(CONSERVATION_REPUTATION_GAIN)
          end
          @zoo.save(zoo)
        end
      end
    end
  end
end
