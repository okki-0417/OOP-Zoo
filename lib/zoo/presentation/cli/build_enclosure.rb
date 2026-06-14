# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class BuildEnclosure < Command
        def run(args)
          name, celsius, capacity = args
          raise ArgumentError, '使い方: build-enclosure NAME CELSIUS CAPACITY' if [name, celsius, capacity].any?(&:nil?)

          command = Application::Commands::AddEnclosureCommand.new(
            name: name,
            temperature: Domain::Shared::Temperature.celsius(Integer(celsius)),
            capacity: Integer(capacity)
          )
          enclosure = @container.add_enclosure.call(command)
          @output.puts "エリアを作成しました: #{enclosure.name}（id=#{enclosure.id}）"
        end
      end
    end
  end
end
