# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Treat < Command
        def run(args)
          veterinarian_id, animal_id = args
          raise ArgumentError, '使い方: treat VET_ID ANIMAL_ID' if [veterinarian_id, animal_id].any?(&:nil?)

          command = Application::Commands::TreatAnimalCommand.new(veterinarian_id: veterinarian_id, animal_id: animal_id)
          animal = @container.treat_animal.call(command)
          @output.puts "治療しました: #{animal.name}"
        end
      end
    end
  end
end
