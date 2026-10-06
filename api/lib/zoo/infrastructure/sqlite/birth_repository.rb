# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BirthRepository
        include Domain::Repositories::BirthRepository

        DEFAULT_MAX_DEPTH = 20

        def initialize(database, animals, mapper: BirthMapper.new)
          @database = database
          @animals = animals
          @mapper = mapper
        end

        def save(birth)
          births.insert_conflict(:replace).insert(@mapper.to_row(birth))
          birth
        end

        def all
          build_births(births.order(:rowid).all)
        end

        def ancestry(*animals, max_depth: DEFAULT_MAX_DEPTH)
          ids = animals.map { |animal| animal.id.to_s }
          return [] if ids.empty?

          placeholders = (['?'] * ids.size).join(', ')
          build_births(@database.execute(ancestry_sql(placeholders), *ids, max_depth))
        end

        private

        def births
          @database.dataset(:births)
        end

        def build_births(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          lookup = animal_lookup(rows)
          rows.filter_map { |row| @mapper.to_aggregate(row, lookup) }
        end

        def animal_lookup(rows)
          ids = rows.flat_map { |row| [row['sire_id'], row['dam_id'], row['offspring_id']] }
          animals = @animals.find_all(ids.compact)
          ->(id) { animals[id.to_s] }
        end

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
