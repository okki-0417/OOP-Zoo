# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class AddEnclosure < Action
        def call(params)
          command = Application::Commands::AddEnclosureCommand.new(
            name: params['name'],
            temperature: Domain::Shared::Temperature.celsius(Integer(params['celsius'])),
            capacity: Integer(params['capacity'])
          )
          enclosure = @container.add_enclosure.call(command)
          [201, { id: enclosure.id.to_s, name: enclosure.name }]
        end
      end
    end
  end
end
