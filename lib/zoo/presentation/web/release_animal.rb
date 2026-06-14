# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ReleaseAnimal < Action
        def call(params)
          command = Application::Commands::ReleaseAnimalCommand.new(animal_id: params['animal_id'])
          animal = @container.release_animal.call(command)
          [200, Serializer.animal(@container.animal_detail.call(animal.id))]
        end
      end
    end
  end
end
