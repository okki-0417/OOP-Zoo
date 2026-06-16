# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class EnclosureRepository
        include Domain::Repositories::EnclosureRepository

        def initialize(database, animal_repository, mapper: EnclosureMapper.new)
          @database = database
          @animals = animal_repository
          @mapper = mapper
        end

        def find(id)
          row = @database.get_first_row('SELECT * FROM enclosures WHERE id = ?', id.to_s)
          row && build(row)
        end

        def save(enclosure)
          row = @mapper.to_row(enclosure)
          @database.execute(
            'INSERT OR REPLACE INTO enclosures (id, name, celsius, capacity, cleanliness, occupant_ids) ' \
            'VALUES (?, ?, ?, ?, ?, ?)',
            row[:id], row[:name], row[:celsius], row[:capacity], row[:cleanliness], row[:occupant_ids]
          )
          enclosure
        end

        def all
          @database.execute('SELECT * FROM enclosures').map { |row| build(row) }
        end

        private

        def build(row)
          occupants = @mapper.occupant_ids(row).map { |id| @animals.find(id) }.compact
          @mapper.to_aggregate(row, occupants)
        end
      end
    end
  end
end
