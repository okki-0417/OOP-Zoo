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
            ApplicationRecord.transaction do
              dam = Domain::Animal.find_by(id: @command.dam_id)
              raise Errors::AnimalNotFound, "動物 #{@command.dam_id} は存在しません" if dam.nil?

              enclosure = Domain::Enclosure.find_by(id: @command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              breeding = Domain::Breeding.latest_of(dam)
              raise Errors::BreedingNotFound, "動物 #{@command.dam_id} の受胎記録がありません" if breeding.nil?

              verify_keeper
              zoo = Domain::Zoo.current

              child = Domain::Birth.new(sire: breeding.sire, dam: dam).deliver.offspring
              Domain::Housing.new(animal: child, enclosure:, occupancy: Domain::Occupancy.of(enclosure)).perform

              dam.save!
              child.save!

              zoo.generate_buzz(BIRTH_BUZZ)
              zoo.save!

              child
            end
          end
        end

        private

        def verify_keeper
          return if @command.keeper_id.nil? || Domain::Keeper.exists?(id: @command.keeper_id)

          raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません"
        end
      end
    end
  end
end
