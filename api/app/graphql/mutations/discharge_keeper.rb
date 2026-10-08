# frozen_string_literal: true

module Mutations
  class DischargeKeeper < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :keeper_id, ID

    def resolve(enclosure_id:, keeper_id:)
      enclosure = Enclosure.find(enclosure_id)
      Relieving.new(keeper: Keeper.find(keeper_id), enclosure:).perform
      enclosure
    end
  end
end
