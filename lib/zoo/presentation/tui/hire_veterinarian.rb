# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class HireVeterinarian < Action
        def call
          name = @prompt.ask('獣医名:')

          vet = @container.hire_veterinarian.call(
            Application::Commands::HireVeterinarianCommand.new(name: name)
          )
          @output.puts "採用しました: #{vet.name}"
        end
      end
    end
  end
end
