# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ExamineAnimal < Action
        def call(params)
          command = Application::Commands::ExamineAnimalCommand.new(
            veterinarian_id: params['veterinarian_id'], animal_id: params['id']
          )
          result = @container.examine_animal.call(command)
          [200, { animal_id: params['id'], result: result.to_s }]
        end
      end
    end
  end
end
