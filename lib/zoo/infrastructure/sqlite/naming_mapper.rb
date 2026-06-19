# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class NamingMapper
        def to_row(event)
          {
            animal_id: event.animal.id.to_s,
            name: event.name,
            keeper_id: event.keeper_id&.to_s,
            occurred_on: event.occurred_on
          }
        end
      end
    end
  end
end
