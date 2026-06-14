# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class AcquireAnimal < Action
        def call(params)
          species = Domain::Taxonomy::SpeciesCatalog.find(params['species']) or
            raise ArgumentError, "未知の種です: #{params['species']}"

          command = Application::Commands::AcquireAnimalCommand.new(
            species: species, name: params['name'],
            sex: Domain::Animal::Sex.new(params['sex'].to_s), max_health: 100
          )
          animal = @container.acquire_animal.call(command)
          [201, Serializer.animal(@container.animal_detail.call(animal.id))]
        end
      end
    end
  end
end
