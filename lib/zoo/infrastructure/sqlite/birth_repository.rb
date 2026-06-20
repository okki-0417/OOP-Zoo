# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BirthRepository
        include Domain::Repositories::BirthRepository

        COLUMNS = %i[id sire_id dam_id offspring_id day season].freeze
        DEFAULT_MAX_DEPTH = 20

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

        def ancestry(*animals, max_depth: DEFAULT_MAX_DEPTH)
          ids = animals.map { |animal| animal.id.to_s }
          return [] if ids.empty?

          placeholders = (['?'] * ids.size).join(', ')
          @database.execute(ancestry_sql(placeholders), *ids, max_depth)
                   .filter_map { |row| @mapper.to_aggregate(row, @animals.method(:find)) }
        end

        private

        def ancestry_sql(placeholders)
          <<~SQL
            WITH RECURSIVE ancestry(id, sire_id, dam_id, offspring_id, day, season, depth) AS (
              SELECT id, sire_id, dam_id, offspring_id, day, season, 0
              FROM births
              WHERE offspring_id IN (#{placeholders})
              UNION
              SELECT b.id, b.sire_id, b.dam_id, b.offspring_id, b.day, b.season, a.depth + 1
              FROM births b
              JOIN ancestry a ON b.offspring_id IN (a.sire_id, a.dam_id)
              WHERE a.depth + 1 < ?
            )
            SELECT DISTINCT id, sire_id, dam_id, offspring_id, day, season FROM ancestry
          SQL
        end
      end
    end
  end
end
