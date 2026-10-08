# frozen_string_literal: true

module Mutations
  class EnrichEnclosure < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :keeper_id, ID

    def resolve(enclosure_id:, keeper_id:)
      Enriching.new(keeper: Keeper.find(keeper_id), enclosure: Enclosure.find(enclosure_id)).perform
    end
  end
end
