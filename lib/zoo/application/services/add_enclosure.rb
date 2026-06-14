# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AddEnclosure
        def initialize(enclosures:, unit_of_work:)
          @enclosures = enclosures
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            enclosure = Domain::Husbandry::Enclosure.new(
              name: command.name,
              temperature: command.temperature,
              capacity: command.capacity
            )
            @enclosures.save(enclosure)
            enclosure
          end
        end
      end
    end
  end
end
