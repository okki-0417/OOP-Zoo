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
            @command.unit_of_work.run do
              sire = @command.animals.find(@command.sire_id)
              raise Errors::AnimalNotFound, "動物 #{@command.sire_id} は存在しません" if sire.nil?

              dam = @command.animals.find(@command.dam_id)
              raise Errors::AnimalNotFound, "動物 #{@command.dam_id} は存在しません" if dam.nil?

              zoo = @command.zoo.load

              breeding = Domain::Breeding.new(sire:, dam:, day: zoo.day, season: zoo.season,
                                              births: @command.births.ancestry(sire, dam))
              breeding.conceive

              @command.animals.save(dam)
              @command.breedings.save(breeding)
            end
            nil
          end
        end
      end
    end
  end
end
