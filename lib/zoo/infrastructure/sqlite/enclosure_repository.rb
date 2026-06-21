# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class EnclosureRepository
        include Domain::Repositories::EnclosureRepository

        def initialize(database, mapper: EnclosureMapper.new)
          @database = database
          @mapper = mapper
        end

        def find(id)
          row = @database.get_first_row('SELECT * FROM enclosures WHERE id = ?', id.to_s)
          row && @mapper.to_aggregate(row)
        end

        def save(enclosure)
          row = @mapper.to_row(enclosure)
          @database.execute(
            'INSERT OR REPLACE INTO enclosures (id, name, celsius, capacity, cleanliness) ' \
            'VALUES (?, ?, ?, ?, ?)',
            row[:id], row[:name], row[:celsius], row[:capacity], row[:cleanliness]
          )
          enclosure
        end

        def all
          @database.execute('SELECT * FROM enclosures').map { |row| @mapper.to_aggregate(row) }
        end
      end
    end
  end
end
