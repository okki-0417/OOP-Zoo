# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HireKeeper
        def initialize(keepers:, unit_of_work:)
          @keepers = keepers
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            keeper = Domain::Staff::Keeper.new(name: command.name, specialties: command.specialties)
            @keepers.save(keeper)
            keeper
          end
        end
      end
    end
  end
end
