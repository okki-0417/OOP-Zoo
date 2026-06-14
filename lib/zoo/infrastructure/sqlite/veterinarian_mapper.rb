# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class VeterinarianMapper
        def to_row(veterinarian)
          { id: veterinarian.id.to_s, name: veterinarian.name }
        end

        def to_aggregate(row)
          Domain::Staff::Veterinarian.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']), name: row['name']
          )
        end
      end
    end
  end
end
