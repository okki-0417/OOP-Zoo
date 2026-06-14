# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class BuildEnclosure < Action
        def call
          name = @prompt.ask('エリア名:')
          celsius = @prompt.ask('気温(℃):', convert: :int)
          capacity = @prompt.ask('定員:', convert: :int)

          command = Application::Commands::AddEnclosureCommand.new(
            name: name,
            temperature: Domain::Shared::Temperature.celsius(celsius),
            capacity: capacity
          )
          enclosure = @container.add_enclosure.call(command)
          @output.puts "エリアを作成: #{enclosure.name}"
        end
      end
    end
  end
end
