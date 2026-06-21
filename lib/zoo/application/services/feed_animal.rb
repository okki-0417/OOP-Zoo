# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class FeedAnimal
        def initialize(keepers:, animals:, unit_of_work:)
          @keepers = keepers
          @animals = animals
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            keeper = @keepers.find(command.keeper_id)
            raise Errors::KeeperNotFound, "飼育員 #{command.keeper_id} は存在しません" if keeper.nil?

            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            Domain::Feeding.new(keeper: keeper, animal: animal, foods: [command.food]).serve
            @animals.save(animal)
            animal
          end
        end
      end
    end
  end
end
