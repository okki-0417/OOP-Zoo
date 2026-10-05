# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ReleaseAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:release_animal) do
            animal = @command.unit_of_work.run do
              animal = @command.animals.find(@command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              current = @command.housings.current_housing_of(animal)
              raise ArgumentError, "#{animal.name}はどのエリアにも収容されていません" if current.nil?

              @command.housings.save(Domain::Releasing.of(current))
              animal
            end
            { animal:, enclosure: nil }
          end
        end
      end
    end
  end
end
