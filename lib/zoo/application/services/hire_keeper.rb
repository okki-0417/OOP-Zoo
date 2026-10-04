# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HireKeeper
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:hire_keeper) do
            keeper = @command.unit_of_work.run do
              specialties = @command.specialties.map { |key| Domain::TaxonClass.new(key) }
              keeper = Domain::Keeper.new(name: @command.name, specialties: specialties)

              zoo = @command.zoo.load
              zoo.purchase(Domain::Keeper.signing_fee)
              @command.zoo.save(zoo)

              @command.keepers.save(keeper)
              keeper
            end
            ReadModels::KeeperSummary.of(keeper)
          end
        end
      end
    end
  end
end
