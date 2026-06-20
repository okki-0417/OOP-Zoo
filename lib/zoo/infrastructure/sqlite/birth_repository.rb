# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BirthRepository
        include Domain::Repositories::BirthRepository

        COLUMNS = %i[id sire_id dam_id offspring_id day season].freeze

        def initialize(database, animals, mapper: BirthMapper.new)
          @database = database
          @animals = animals
          @mapper = mapper
        end

        def save(birth)
          row = @mapper.to_row(birth)
          @database.execute(
            "INSERT OR REPLACE INTO births (#{COLUMNS.join(', ')}) VALUES (#{(['?'] * COLUMNS.size).join(', ')})",
            *COLUMNS.map { |column| row[column] }
          )
          birth
        end

        def all
          @database.execute('SELECT * FROM births ORDER BY rowid')
                   .filter_map { |row| @mapper.to_aggregate(row, @animals.method(:find)) }
        end
      end
    end
  end
end
