# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class HousingRepository
        include Domain::Repositories::HousingRepository

        COLUMNS = %i[id animal_id enclosure_id kind occurred_on keeper_id closes_housing_id].freeze

        EVENTS_FOR_ENCLOSURE = <<~SQL
          SELECT * FROM housing_events
          WHERE (enclosure_id = ? AND kind = ?)
             OR (kind = ? AND closes_housing_id IN
                 (SELECT id FROM housing_events WHERE enclosure_id = ? AND kind = ?))
          ORDER BY seq
        SQL

        CURRENT_HOUSING_OF = <<~SQL
          SELECT * FROM housing_events h
          WHERE h.animal_id = ? AND h.kind = ?
            AND NOT EXISTS (SELECT 1 FROM housing_events r
                            WHERE r.kind = ? AND r.closes_housing_id = h.id)
          ORDER BY seq DESC LIMIT 1
        SQL

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
          build_events(@database.execute('SELECT * FROM housing_events ORDER BY seq'))
        end

        def events_for_enclosure(enclosure_id)
          build_events(
            @database.execute(
              EVENTS_FOR_ENCLOSURE,
              enclosure_id.to_s, HousingMapper::HOUSED,
              HousingMapper::RELEASED, enclosure_id.to_s, HousingMapper::HOUSED
            )
          )
        end

        def current_housing_of(animal)
          build_events(
            @database.execute(
              CURRENT_HOUSING_OF, animal.id.to_s, HousingMapper::HOUSED, HousingMapper::RELEASED
            )
          ).first
        end

        private

        def build_events(rows)
          housings = {}
          rows.filter_map do |row|
            event = @mapper.to_aggregate(row, @animals.method(:find), housings)
            housings[event.id.to_s] = event if event.is_a?(Domain::Housing)
            event
          end
        end
      end
    end
  end
end
