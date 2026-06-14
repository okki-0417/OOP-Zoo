# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class VeterinarianRepository
        include Domain::Repositories::VeterinarianRepository

        def initialize(database, mapper: VeterinarianMapper.new)
          @database = database
          @mapper = mapper
        end

        def find(id)
          row = @database.get_first_row('SELECT * FROM veterinarians WHERE id = ?', id.to_s)
          row && @mapper.to_aggregate(row)
        end

        def save(veterinarian)
          row = @mapper.to_row(veterinarian)
          @database.execute('INSERT OR REPLACE INTO veterinarians (id, name) VALUES (?, ?)', row[:id], row[:name])
          veterinarian
        end

        def all
          @database.execute('SELECT * FROM veterinarians').map { |row| @mapper.to_aggregate(row) }
        end
      end
    end
  end
end
