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

        def find_all(ids)
          keys = ids.map(&:to_s).uniq
          return {} if keys.empty?

          enclosures.where(id: keys).each_with_object({}) do |row, found|
            enclosure = @mapper.to_aggregate(row.transform_keys(&:to_s))
            found[enclosure.id.to_s] = enclosure
          end
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
