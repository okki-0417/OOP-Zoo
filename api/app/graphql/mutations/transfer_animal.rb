# frozen_string_literal: true

module Mutations
  class TransferAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :enclosure_id, ID

    def resolve(animal_id:, enclosure_id:)
      enclosure = Enclosure.find(enclosure_id)
      Housing.new(animal: Animal.find(animal_id), enclosure:).perform
    end
  end
end
