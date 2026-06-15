# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HireKeeper
        def initialize(keepers:, zoo:, unit_of_work:)
          @keepers = keepers
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            keeper = Domain::Staff::Keeper.new(name: command.name, specialties: command.specialties)

            charge(Domain::Operations::Pricing.keeper_signing_fee)
            @keepers.save(keeper)
            keeper
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
