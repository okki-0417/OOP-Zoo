# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class RenameAnimal < Action
        def call(params)
          command = Application::Commands::RenameAnimalCommand.new(
            animal_id: params['id'], new_name: params['name']
          )
          animal = @container.rename_animal.call(command)
          [200, Serializer.animal(@container.animal_detail.call(animal.id))]
        end
      end
    end
  end
end
