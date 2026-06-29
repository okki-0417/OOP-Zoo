# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ConceiveAnimals
        def initialize(animals:, breedings:, births:, zoo:, unit_of_work:)
          @animals = animals
          @breedings = breedings
          @births = births
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            sire = @animals.find(command.sire_id)
            raise Errors::AnimalNotFound, "動物 #{command.sire_id} は存在しません" if sire.nil?

            dam = @animals.find(command.dam_id)
            raise Errors::AnimalNotFound, "動物 #{command.dam_id} は存在しません" if dam.nil?

            zoo = @zoo.load

            breeding = Domain::Breeding.new(sire:, dam:, day: zoo.day, season: zoo.season,
                                            births: @births.ancestry(sire, dam))
            breeding.conceive

            @animals.save(dam)
            @breedings.save(breeding)
          end
          nil
        end
      end
    end
  end
end
