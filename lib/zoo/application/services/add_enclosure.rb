# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AddEnclosure
        def initialize(enclosures:, zoo:, unit_of_work:)
          @enclosures = enclosures
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            enclosure = Domain::Enclosure.new(
              name: command.name,
              temperature: command.temperature,
              capacity: command.capacity
            )

            charge(Domain::Pricing.enclosure_construction_cost(capacity: command.capacity))
            @enclosures.save(enclosure)
            enclosure
          end
        end

        private

        def charge(price)
          zoo = @zoo.load
          zoo.purchase(price)
          @zoo.save(zoo)
        end
      end
    end
  end
end
