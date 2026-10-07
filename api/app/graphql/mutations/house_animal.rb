# frozen_string_literal: true

module Mutations
  class HouseAnimal < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :animal_id, ID

    def resolve(enclosure_id:, animal_id:)
      enclosure = Enclosure.find(enclosure_id)
      Housing.new(animal: Animal.find(animal_id), enclosure:).perform
      enclosure
    end
  end
end
