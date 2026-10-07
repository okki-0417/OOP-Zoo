# frozen_string_literal: true

module Mutations
  class EnrichEnclosure < BaseMutation
    type Types::Enclosure, null: false

    argument :enclosure_id, ID
    argument :keeper_id, ID

    def resolve(**)
      perform(:enrich_enclosure, **)
    end
  end
end
