# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AnimalRepository
        include Domain::Repositories::AnimalRepository

        COLUMNS = %i[
          id species_key name sex health_current health_max hunger stress age_in_days
          illness_key immunities death_cause parent_ids
        ].freeze

        BIRTH_COLUMNS = %i[sire_id dam_id offspring_id occurred_on season].freeze

        def initialize(database, mapper: AnimalMapper.new, birth_mapper: BirthMapper.new)
          @database = database
          @mapper = mapper
          @birth_mapper = birth_mapper
        end

        def find(id)
          row = @database.get_first_row('SELECT * FROM animals WHERE id = ?', id.to_s)
          row && @mapper.to_aggregate(row)
        end

        def save(animal)
          row = @mapper.to_row(animal)
          @database.execute(
            "INSERT OR REPLACE INTO animals (#{COLUMNS.join(', ')}) VALUES (#{(['?'] * COLUMNS.size).join(', ')})",
            *COLUMNS.map { |column| row[column] }
          )
          animal.recorded_events.grep(Domain::Events::Birth).each { |birth| append_birth(birth) }
          animal
        end

        def all
          @database.execute('SELECT * FROM animals').map { |row| @mapper.to_aggregate(row) }
        end

        def births
          @database.execute('SELECT * FROM births ORDER BY id')
                   .filter_map { |row| @birth_mapper.to_aggregate(row, method(:find)) }
        end

        private

        def append_birth(birth)
          row = @birth_mapper.to_row(birth)
          @database.execute(
            "INSERT INTO births (#{BIRTH_COLUMNS.join(', ')}) VALUES (#{(['?'] * BIRTH_COLUMNS.size).join(', ')})",
            *BIRTH_COLUMNS.map { |column| row[column] }
          )
        end
      end
    end
  end
end
