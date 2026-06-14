# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class TransferAnimal < Action
        def call(params)
          command = Application::Commands::TransferAnimalCommand.new(
            animal_id: params['id'], enclosure_id: params['enclosure_id']
          )
          @container.transfer_animal.call(command)
          [200, Serializer.animal(@container.animal_detail.call(params['id']))]
        end
      end
    end
  end
end
