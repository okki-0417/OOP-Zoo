# frozen_string_literal: true

module Mutations
  class AssignKeeper < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :keeper_id, ID

    def resolve(**)
      perform(:assign_keeper, **)
    end
  end
end
