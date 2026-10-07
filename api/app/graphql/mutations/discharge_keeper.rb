# frozen_string_literal: true

module Mutations
  class DischargeKeeper < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :keeper_id, ID

    def resolve(**)
      perform(:discharge_keeper, **)
    end
  end
end
