# frozen_string_literal: true

module Mutations
  class MakeRounds < BaseMutation
    type Types::Rounds, null: false

    argument :keeper_id, ID

    def resolve(keeper_id:)
      keeper = Keeper.find(keeper_id)
      reports = keeper.enclosures.map do |enclosure|
        Rounding.new(keeper:, occupancy: Occupancy.of(enclosure), foods: FoodCatalog.all).perform
      end
      { keeper:, reports: }
    end
  end
end
