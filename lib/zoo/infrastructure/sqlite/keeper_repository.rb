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
          row = keepers.where(id: id.to_s).first
          row && @mapper.to_aggregate(row.transform_keys(&:to_s))
        end

        def save(keeper)
          keepers.insert_conflict(:replace).insert(@mapper.to_row(keeper))
          keeper
        end

        def all
          keepers.all.map { |row| @mapper.to_aggregate(row.transform_keys(&:to_s)) }
        end

        private

        def keepers
          @database.dataset(:keepers)
        end
      end
    end
  end
end
