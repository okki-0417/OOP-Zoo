# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class HousingRepository
        include Domain::Repositories::HousingRepository

        HOUSED = HousingMapper::HOUSED
        RELEASED = HousingMapper::RELEASED

        def initialize(database, animals, enclosures, mapper: HousingMapper.new)
          @database = database
          @animals = animals
          @enclosures = enclosures
          @mapper = mapper
        end

        def save(event)
          events.insert(@mapper.to_row(event))
          event
        end

        def all
          build_events(events.order(:seq).all)
        end

        def current_housing_of(animal)
          build_events(current_housings.where(animal_id: animal.id.to_s).all).first
        end

        def occupants_of(enclosure)
          occupants(current_housings.where(enclosure_id: enclosure.id.to_s))
        end

        def all_occupants
          occupants(current_housings)
        end

        private

        def events
          @database.dataset(:housing_events)
        end

        def current_housings
          closed = events.where(kind: RELEASED).exclude(closes_housing_id: nil).select(:closes_housing_id)
          live = events.where(kind: HOUSED).exclude(id: closed)
          live.where(seq: live.group(:animal_id).select { max(:seq) })
        end

        def occupants(dataset)
          build_events(dataset.order(:seq).all).filter_map do |housing|
            housing.animal if housing.animal.alive?
          end
        end

        def build_events(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          animal_lookup = animal_lookup(rows)
          enclosure_lookup = enclosure_lookup(rows)
          housings = {}
          rows.filter_map do |row|
            event = @mapper.to_aggregate(row, animal_lookup, enclosure_lookup, housings)
            housings[event.id.to_s] = event if event.is_a?(Domain::Housing)
            event
          end
        end

        def animal_lookup(rows)
          animals = @animals.find_all(rows.filter_map { |row| row['animal_id'] })
          ->(id) { animals[id.to_s] }
        end

        def enclosure_lookup(rows)
          enclosures = @enclosures.find_all(rows.filter_map { |row| row['enclosure_id'] })
          ->(id) { enclosures[id.to_s] }
        end
      end
    end
  end
end
