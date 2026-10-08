# frozen_string_literal: true

module Mutations
  class CleanEnclosure < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :keeper_id, ID

    def resolve(enclosure_id:, keeper_id:)
      Cleaning.new(keeper: current_zoo.keepers.find(keeper_id), enclosure: current_zoo.enclosures.find(enclosure_id)).perform
    end
  end
end
