# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ConceiveAnimals
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:conceive_animals) do
            ApplicationRecord.transaction do
              sire = Domain::Animal.find_by(id: @command.sire_id)
              raise Errors::AnimalNotFound, "動物 #{@command.sire_id} は存在しません" if sire.nil?

              dam = Domain::Animal.find_by(id: @command.dam_id)
              raise Errors::AnimalNotFound, "動物 #{@command.dam_id} は存在しません" if dam.nil?

              zoo = Domain::Zoo.current

              breeding = Domain::Breeding.new(sire:, dam:, day: zoo.day, season: zoo.season)
              breeding.conceive

              dam.save!
              breeding.save!
            end
            nil
          end
        end
      end
    end
  end
end
