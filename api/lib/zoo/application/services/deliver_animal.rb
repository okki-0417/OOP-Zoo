# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class DeliverAnimal
        BIRTH_BUZZ = 40

        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:deliver_animal) do
            @command.unit_of_work.run do
              dam = @command.animals.find(@command.dam_id)
              raise Errors::AnimalNotFound, "動物 #{@command.dam_id} は存在しません" if dam.nil?

              enclosure = @command.enclosures.find(@command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              keeper = find_keeper

              breeding = @command.breedings.for_dam(dam.id)
              raise Errors::BreedingNotFound, "動物 #{@command.dam_id} の受胎記録がありません" if breeding.nil?

              zoo = @command.zoo.load

              birth = Domain::Birth.new(
                sire: breeding.sire, dam: dam, occurred_on: zoo.day, season: zoo.season, keeper_id: keeper&.id
              ).deliver
              child = birth.offspring

              occupancy = @command.housings.all_occupancies.find { |o| o.enclosure == enclosure } ||
                          Domain::Occupancy.new(housings: [], enclosure: enclosure)
              housing = Domain::Housing.new(
                animal: child, enclosure: enclosure, occupancy: occupancy, occurred_on: zoo.day, keeper_id: keeper&.id
              )
              housing.admission_violation!

              @command.animals.save(dam)
              @command.animals.save(child)
              @command.births.save(birth)
              @command.housings.save(housing)

              zoo.generate_buzz(BIRTH_BUZZ)
              @command.zoo.save(zoo)

              child
            end
          end
        end

        private

        def find_keeper
          return nil if @command.keeper_id.nil?

          keeper = @command.keepers.find(@command.keeper_id)
          raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

          keeper
        end
      end
    end
  end
end
