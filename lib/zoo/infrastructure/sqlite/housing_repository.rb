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

        def events_for_enclosure(enclosure_id)
          housed_here = events.where(enclosure_id: enclosure_id.to_s, kind: HOUSED)
          scoped = events.where(
            Sequel.|(
              { enclosure_id: enclosure_id.to_s, kind: HOUSED },
              { kind: RELEASED, closes_housing_id: housed_here.select(:id) }
            )
          )
          build_events(scoped.order(:seq).all)
        end

        def current_housing_of(animal)
          released = events.where(kind: RELEASED).exclude(closes_housing_id: nil).select(:closes_housing_id)
          current = events.where(animal_id: animal.id.to_s, kind: HOUSED)
                          .exclude(id: released)
                          .order(Sequel.desc(:seq)).limit(1)
          build_events(current.all).first
        end

        def occupants_of(enclosure)
          Domain::Occupancy.new(events_for_enclosure(enclosure.id)).occupants_of(enclosure)
        end

        def all_occupants
          Domain::Occupancy.new(all).all_occupants
        end

        private

        def events
          @database.dataset(:housing_events)
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
