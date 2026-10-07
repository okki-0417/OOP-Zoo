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
            ApplicationRecord.transaction do
              specialties = @command.specialties.map { |key| Domain::TaxonClass.new(key) }
              keeper = Domain::Keeper.new(name: @command.name, specialties: specialties)

              zoo = Domain::Zoo.current
              zoo.purchase(Domain::Keeper.signing_fee)
              zoo.save!

              keeper.save!
              keeper
            end
          end
        end
      end
    end
  end
end
