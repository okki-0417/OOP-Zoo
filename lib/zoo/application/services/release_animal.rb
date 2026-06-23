# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ReleaseAnimal
        def initialize(animals:, housings:, unit_of_work:)
          @animals = animals
          @housings = housings
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            current = @housings.current_housing_of(animal)
            raise ArgumentError, "#{animal.name}はどのエリアにも収容されていません" if current.nil?

            @housings.save(Domain::Releasing.of(current))
            animal
          end
        end
      end
    end
  end
end
