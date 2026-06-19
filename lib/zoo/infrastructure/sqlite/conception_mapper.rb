# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class ConceptionMapper
        Domain = Zoo::Domain

        def to_row(event)
          {
            dam_id: event.dam.id.to_s,
            sire_id: event.sire_id.to_s,
            sex: event.sex.value.to_s,
            inbreeding_coefficient: event.inbreeding_coefficient,
            keeper_id: event.keeper_id&.to_s,
            occurred_on: event.occurred_on,
            season: event.season.value.to_s
          }
        end
      end
    end
  end
end
