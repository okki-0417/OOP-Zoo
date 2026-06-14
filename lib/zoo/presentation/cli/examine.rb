# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Examine < Command
        LABELS = { healthy: '健康', sick: '病気', injured: '衰弱', dead: '死亡' }.freeze

        def run(args)
          veterinarian_id, animal_id = args
          raise ArgumentError, '使い方: examine VET_ID ANIMAL_ID' if [veterinarian_id, animal_id].any?(&:nil?)

          command = Application::Commands::ExamineAnimalCommand.new(
            veterinarian_id: veterinarian_id, animal_id: animal_id
          )
          diagnosis = @container.examine_animal.call(command)
          @output.puts "診断: #{LABELS.fetch(diagnosis, diagnosis)}"
        end
      end
    end
  end
end
