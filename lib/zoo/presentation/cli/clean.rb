# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Clean < Command
        def run(args)
          keeper_id, enclosure_id, amount = args
          raise ArgumentError, '使い方: clean KEEPER_ID ENCLOSURE_ID [AMOUNT]' if [keeper_id, enclosure_id].any?(&:nil?)

          command = Application::Commands::CleanEnclosureCommand.new(
            keeper_id: keeper_id, enclosure_id: enclosure_id, amount: amount ? Integer(amount) : 100
          )
          enclosure = @container.clean_enclosure.call(command)
          @output.puts "清掃しました: #{enclosure.name}（清潔度 #{enclosure.cleanliness.level}）"
        end
      end
    end
  end
end
