# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AnimalPrognosis
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:animal_prognosis) do
            animal = @command.animals.find(@command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

            occupancy = @command.housings.all_occupancies.find { |candidate| candidate.include?(animal) }
            next { animal:, prognosis: nil } if occupancy.nil?

            {
              animal:,
              prognosis: Domain::Prognosis.new(
                animal:, enclosure: occupancy.enclosure, occupancy:, season: @command.zoo.load.season
              )
            }
          end
        end
      end
    end
  end
end
