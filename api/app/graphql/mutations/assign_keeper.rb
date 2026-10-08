# frozen_string_literal: true

module Mutations
  class AssignKeeper < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :keeper_id, ID

    def resolve(enclosure_id:, keeper_id:)
      enclosure = current_zoo.enclosures.find(enclosure_id)
      Tending.new(keeper: current_zoo.keepers.find(keeper_id), enclosure:).perform
      enclosure
    end
  end
end
