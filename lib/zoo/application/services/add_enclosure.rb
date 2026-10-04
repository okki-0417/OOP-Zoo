# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AddEnclosure
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:add_enclosure) do
            enclosure = @command.unit_of_work.run do
              enclosure = Domain::Enclosure.new(
                name: @command.name,
                temperature: Domain::Shared::Temperature.celsius(@command.celsius),
                capacity: @command.capacity
              )

              zoo = @command.zoo.load
              zoo.purchase(Domain::Enclosure.construction_cost(capacity: @command.capacity))
              @command.zoo.save(zoo)

              @command.enclosures.save(enclosure)
              enclosure
            end
            ReadModels::EnclosureProfile.of(enclosure, occupants: [])
          end
        end
      end
    end
  end
end
