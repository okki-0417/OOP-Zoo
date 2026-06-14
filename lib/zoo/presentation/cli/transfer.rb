# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Transfer < Command
        def run(args)
          animal_id, enclosure_id = args
          raise ArgumentError, '使い方: transfer ANIMAL_ID TO_ENCLOSURE_ID' if [animal_id, enclosure_id].any?(&:nil?)

          command = Application::Commands::TransferAnimalCommand.new(animal_id: animal_id, enclosure_id: enclosure_id)
          enclosure = @container.transfer_animal.call(command)
          @output.puts "移送しました: #{enclosure.name}（在園 #{enclosure.population}頭）"
        end
      end
    end
  end
end
