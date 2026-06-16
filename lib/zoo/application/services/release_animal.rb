# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ReleaseAnimal
        def initialize(enclosures:, animals:, unit_of_work:)
          @enclosures = enclosures
          @animals = animals
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            enclosure = @enclosures.all.find { |e| e.houses?(animal) }
            raise ArgumentError, "#{animal.name}はどのエリアにも収容されていません" if enclosure.nil?

            enclosure.release(animal)
            @enclosures.save(enclosure)
            animal
          end
        end
      end
    end
  end
end
