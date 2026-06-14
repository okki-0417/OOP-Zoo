# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class KeeperRepository
        include Domain::Repositories::KeeperRepository

        def initialize(database, mapper: KeeperMapper.new)
          @database = database
          @mapper = mapper
        end

        def find(id)
          row = @database.get_first_row('SELECT * FROM keepers WHERE id = ?', id.to_s)
          row && @mapper.to_aggregate(row)
        end

        def save(keeper)
          row = @mapper.to_row(keeper)
          @database.execute(
            'INSERT OR REPLACE INTO keepers (id, name, specialties) VALUES (?, ?, ?)',
            row[:id], row[:name], row[:specialties]
          )
          keeper
        end

        def all
          @database.execute('SELECT * FROM keepers').map { |row| @mapper.to_aggregate(row) }
        end
      end
    end
  end
end
