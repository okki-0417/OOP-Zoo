# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class OperatingRepository
        include Domain::Repositories::OperatingRepository

        def initialize(database, mapper: OperatingMapper.new)
          @database = database
          @mapper = mapper
        end

        def save(operating)
          operatings.insert_conflict(:replace).insert(@mapper.to_row(operating))
          operating
        end

        def all
          operatings.order(:day).all.map { |row| @mapper.to_aggregate(row.transform_keys(&:to_s)) }
        end

        def latest
          row = operatings.order(Sequel.desc(:day)).first
          row && @mapper.to_aggregate(row.transform_keys(&:to_s))
        end

        private

        def operatings
          @database.dataset(:operatings)
        end
      end
    end
  end
end
