# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BreedingRepository
        include Domain::Repositories::BreedingRepository

        COLUMNS = %i[id sire_id dam_id day season].freeze

        def initialize(database, animals, mapper: BreedingMapper.new)
          @database = database
          @animals = animals
          @mapper = mapper
        end

        def save(breeding)
          row = @mapper.to_row(breeding)
          @database.execute(
            "INSERT OR REPLACE INTO breedings (#{COLUMNS.join(', ')}) VALUES (#{(['?'] * COLUMNS.size).join(', ')})",
            *COLUMNS.map { |column| row[column] }
          )
          breeding
        end

        def all
          @database.execute('SELECT * FROM breedings ORDER BY rowid')
                   .filter_map { |row| @mapper.to_aggregate(row, @animals.method(:find)) }
        end

        def for_dam(dam_id)
          row = @database.get_first_row(
            'SELECT * FROM breedings WHERE dam_id = ? ORDER BY rowid DESC LIMIT 1', dam_id.to_s
          )
          row && @mapper.to_aggregate(row, @animals.method(:find))
        end
      end
    end
  end
end
