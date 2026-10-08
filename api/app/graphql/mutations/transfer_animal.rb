# frozen_string_literal: true

module Mutations
  class TransferAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :enclosure_id, ID

    def resolve(animal_id:, enclosure_id:)
      enclosure = current_zoo.enclosures.find(enclosure_id)
      Housing.new(animal: current_zoo.animals.find(animal_id), enclosure:).perform
    end
  end
end
