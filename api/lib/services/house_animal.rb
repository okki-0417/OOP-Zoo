# frozen_string_literal: true

module Services
  class HouseAnimal
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:house_animal) do
        ApplicationRecord.transaction do
          enclosure = ::Enclosure.find_by(id: @command.enclosure_id)
          raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

          animal = ::Animal.find_by(id: @command.animal_id)
          raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

          ::Housing.new(animal:, enclosure:, occupancy: ::Occupancy.of(enclosure)).perform
          animal.save!
          enclosure
        end
      end
    end
  end
end
