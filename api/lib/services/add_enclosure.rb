# frozen_string_literal: true

module Services
  class AddEnclosure
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:add_enclosure) do
        ApplicationRecord.transaction do
          enclosure = ::Enclosure.new(
            name: @command.name,
            temperature: Temperature.celsius(@command.celsius),
            capacity: @command.capacity,
            climate_controlled: @command.climate_controlled
          )

          zoo = ::Zoo.current
          zoo.purchase(::Enclosure.construction_cost(capacity: @command.capacity,
                                                     climate_controlled: @command.climate_controlled))
          zoo.save!

          enclosure.save!
          enclosure
        end
      end
    end
  end
end
