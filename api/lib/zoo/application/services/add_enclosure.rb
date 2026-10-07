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
            ApplicationRecord.transaction do
              enclosure = Domain::Enclosure.new(
                name: @command.name,
                temperature: Domain::Shared::Temperature.celsius(@command.celsius),
                capacity: @command.capacity,
                climate_controlled: @command.climate_controlled
              )

              zoo = Domain::Zoo.current
              zoo.purchase(Domain::Enclosure.construction_cost(capacity: @command.capacity,
                                                               climate_controlled: @command.climate_controlled))
              zoo.save!

              enclosure.save!
              enclosure
            end
          end
        end
      end
    end
  end
end
