# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class EventStore
        include Application::EventStore

        def initialize(database, animal_repository)
          @database = database
          @animals = animal_repository
        end

        def append(event)
          events.insert(
            type: event.class.name.split('::').last,
            animal_id: event.animal.id.to_s,
            cause: cause_of(event)
          )
          event
        end

        def all
          rows = events.order(:id).all.map { |row| row.transform_keys(&:to_s) }
          animals = @animals.find_all(rows.filter_map { |row| row['animal_id'] })
          rows.filter_map { |row| build(row, animals[row['animal_id']]) }
        end

        private

        def events
          @database.dataset(:events)
        end

        def cause_of(event)
          event.respond_to?(:cause) ? event.cause.to_s : nil
        end

        def build(row, animal)
          return nil unless animal

          case row['type']
          when 'AnimalDied'
            Domain::Events::AnimalDied.new(animal: animal, cause: row['cause'].to_sym)
          when 'AnimalRenamed'
            Domain::Events::AnimalRenamed.new(animal: animal, old_name: animal.name.to_s, new_name: animal.name.to_s)
          end
        end
      end
    end
  end
end
