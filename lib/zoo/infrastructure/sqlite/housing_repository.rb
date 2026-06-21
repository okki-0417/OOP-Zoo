# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class HousingRepository
        include Domain::Repositories::HousingRepository

        COLUMNS = %i[id animal_id enclosure_id kind occurred_on keeper_id closes_housing_id].freeze

        def initialize(database, animals, mapper: HousingMapper.new)
          @database = database
          @animals = animals
          @mapper = mapper
        end

        def save(event)
          row = @mapper.to_row(event)
          @database.execute(
            "INSERT INTO housing_events (#{COLUMNS.join(', ')}) VALUES (#{(['?'] * COLUMNS.size).join(', ')})",
            *COLUMNS.map { |column| row[column] }
          )
          event
        end

        def all
          housings = {}
          @database.execute('SELECT * FROM housing_events ORDER BY seq').filter_map do |row|
            event = @mapper.to_aggregate(row, @animals.method(:find), housings)
            housings[event.id.to_s] = event if event.is_a?(Domain::Housing)
            event
          end
        end
      end
    end
  end
end
