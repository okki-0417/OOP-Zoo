# frozen_string_literal: true

module Services
  class HireKeeper
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:hire_keeper) do
        ApplicationRecord.transaction do
          specialties = @command.specialties.map { |key| ::TaxonClass.new(key) }
          keeper = ::Keeper.new(name: @command.name, specialties: specialties)

          zoo = ::Zoo.current
          zoo.purchase(::Keeper.signing_fee)
          zoo.save!

          keeper.save!
          keeper
        end
      end
    end
  end
end
