# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class EnclosureRepository
        include Domain::Repositories::EnclosureRepository

        def initialize(database, mapper: EnclosureMapper.new)
          @database = database
          @mapper = mapper
        end

        def find(id)
          row = enclosures.where(id: id.to_s).first
          row && @mapper.to_aggregate(row.transform_keys(&:to_s))
        end

        def save(enclosure)
          enclosures.insert_conflict(:replace).insert(@mapper.to_row(enclosure))
          enclosure
        end

        def all
          enclosures.all.map { |row| @mapper.to_aggregate(row.transform_keys(&:to_s)) }
        end

        private

        def enclosures
          @database.dataset(:enclosures)
        end
      end
    end
  end
end
