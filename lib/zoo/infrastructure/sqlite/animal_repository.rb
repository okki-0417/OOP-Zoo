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

        NAMING_COLUMNS = %i[animal_id name keeper_id occurred_on].freeze

        def initialize(database, mapper: AnimalMapper.new, naming_mapper: NamingMapper.new)
          @database = database
          @mapper = mapper
          @naming_mapper = naming_mapper
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
          animal.recorded_events.grep(Domain::Events::AnimalNamed).each { |e| append_naming(e) }
          animal
        end

        def all
          @database.execute('SELECT * FROM animals').map { |row| @mapper.to_aggregate(row) }
        end

        def namings
          @database.execute('SELECT * FROM namings ORDER BY id')
        end

        private

        def append_naming(event)
          row = @naming_mapper.to_row(event)
          @database.execute(
            "INSERT INTO namings (#{NAMING_COLUMNS.join(', ')}) VALUES (#{(['?'] * NAMING_COLUMNS.size).join(', ')})",
            *NAMING_COLUMNS.map { |column| row[column] }
          )
        end
      end
    end
  end
end
