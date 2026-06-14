# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Release < Command
        def run(args)
          animal_id, = args
          raise ArgumentError, '使い方: release ANIMAL_ID' if animal_id.nil?

          animal = @container.release_animal.call(
            Application::Commands::ReleaseAnimalCommand.new(animal_id: animal_id)
          )
          @output.puts "展示から外しました: #{animal.name}"
        end
      end
    end
  end
end
