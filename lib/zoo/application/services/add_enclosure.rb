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
                capacity: @command.capacity,
                climate_controlled: @command.climate_controlled
              )

              zoo = @command.zoo.load
              zoo.purchase(Domain::Enclosure.construction_cost(capacity: @command.capacity,
                                                               climate_controlled: @command.climate_controlled))
              @command.zoo.save(zoo)

              @command.enclosures.save(enclosure)
              enclosure
            end
            ReadModels::EnclosureProfile.of(enclosure, occupants: [], keepers: [])
          end
        end
      end
    end
  end
end
