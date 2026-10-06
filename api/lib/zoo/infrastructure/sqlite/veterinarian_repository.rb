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
          row = veterinarians.where(id: id.to_s).first
          row && @mapper.to_aggregate(row.transform_keys(&:to_s))
        end

        def save(veterinarian)
          veterinarians.insert_conflict(:replace).insert(@mapper.to_row(veterinarian))
          veterinarian
        end

        def all
          veterinarians.all.map { |row| @mapper.to_aggregate(row.transform_keys(&:to_s)) }
        end

        private

        def veterinarians
          @database.dataset(:veterinarians)
        end
      end
    end
  end
end
