# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class HouseAnimal < Action
        def call(params)
          command = Application::Commands::HouseAnimalCommand.new(
            enclosure_id: params['id'], animal_id: params['animal_id']
          )
          enclosure = @container.house_animal.call(command)
          [200, { name: enclosure.name, population: enclosure.population }]
        end
      end
    end
  end
end
