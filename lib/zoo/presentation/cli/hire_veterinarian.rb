# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class HireVeterinarian < Command
        def run(args)
          name, = args
          raise ArgumentError, '使い方: hire-veterinarian NAME' if name.nil?

          command = Application::Commands::HireVeterinarianCommand.new(name: name)
          vet = @container.hire_veterinarian.call(command)
          @output.puts "採用しました（獣医）: #{vet.name}（id=#{vet.id}）"
        end
      end
    end
  end
end
