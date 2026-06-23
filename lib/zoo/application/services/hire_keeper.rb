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
            keeper = Domain::Keeper.new(name: command.name, specialties: command.specialties)

            zoo = @zoo.load
            zoo.purchase(Domain::Keeper.signing_fee)
            @zoo.save(zoo)

            @keepers.save(keeper)
            keeper
          end
        end
      end
    end
  end
end
