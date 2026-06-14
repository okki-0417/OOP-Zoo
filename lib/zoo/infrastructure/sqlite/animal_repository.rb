# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      # AnimalRepository ポートの SQLite 実装。SQL を担い、行⇄集約は AnimalMapper に委譲。
      class AnimalRepository
        include Domain::Repositories::AnimalRepository

        COLUMNS = %i[
          id species_key name sex health_current health_max hunger stress age_in_days illness_key death_cause parent_ids
        ].freeze

        def initialize(database, mapper: AnimalMapper.new)
          @database = database
          @mapper = mapper
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
          animal
        end

        def all
          @database.execute('SELECT * FROM animals').map { |row| @mapper.to_aggregate(row) }
        end
      end
    end
  end
end
