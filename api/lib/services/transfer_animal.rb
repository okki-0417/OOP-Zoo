# frozen_string_literal: true

module Services
  class TransferAnimal
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:transfer_animal) do
        ApplicationRecord.transaction do
          target = ::Enclosure.find_by(id: @command.enclosure_id)
          raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if target.nil?

          animal = ::Animal.find_by(id: @command.animal_id)
          raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

          ::Housing.new(animal:, enclosure: target, occupancy: ::Occupancy.of(target)).perform
          animal.save!
          animal
        end
      end
    end
  end
end
