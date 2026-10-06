# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class ZooRepository
        include Domain::Repositories::ZooRepository

        def initialize(database, default_zoo, mapper: ZooMapper.new)
          @database = database
          @default_zoo = default_zoo
          @mapper = mapper
        end

        def load
          row = zoo.where(id: 1).first
          row ? @mapper.to_zoo(row.transform_keys(&:to_s)) : @default_zoo
        end

        def save(zoo_aggregate)
          zoo.insert_conflict(:replace).insert(@mapper.to_row(zoo_aggregate).merge(id: 1))
          zoo_aggregate
        end

        private

        def zoo
          @database.dataset(:zoo)
        end
      end
    end
  end
end
