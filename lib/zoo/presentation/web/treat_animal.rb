# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class TreatAnimal < Action
        def call(params)
          command = Application::Commands::TreatAnimalCommand.new(
            veterinarian_id: params['veterinarian_id'], animal_id: params['id']
          )
          animal = @container.treat_animal.call(command)
          [200, Serializer.animal(@container.animal_detail.call(animal.id))]
        end
      end
    end
  end
end
