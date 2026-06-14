# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class ExamineAnimal < Action
        LABELS = { healthy: '健康', sick: '病気', injured: '衰弱', dead: '死亡' }.freeze

        def call
          veterinarian_id = choose_veterinarian or return @output.puts('獣医がいません')
          animal_id = choose_animal or return @output.puts('個体がいません')

          diagnosis = @container.examine_animal.call(
            Application::Commands::ExamineAnimalCommand.new(veterinarian_id: veterinarian_id, animal_id: animal_id)
          )
          @output.puts "診断: #{LABELS.fetch(diagnosis, diagnosis)}"
        end
      end
    end
  end
end
