# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      # EventStore ポートの SQLite 実装。種類・対象個体id・死因を保存し、読み出しは
      # AnimalRepository で個体を解決してイベントを再構成する。改名の旧名や誕生の親idの
      # 一部は保存しない(クエリ側が参照しないため)簡略化。
      class EventStore
        include Application::EventStore

        def initialize(database, animal_repository)
          @database = database
          @animals = animal_repository
        end

        def append(event)
          @database.execute(
            'INSERT INTO events (type, animal_id, cause) VALUES (?, ?, ?)',
            event.class.name.split('::').last, event.animal.id.to_s, cause_of(event)
          )
          event
        end

        def all
          @database.execute('SELECT * FROM events ORDER BY id').filter_map { |row| build(row) }
        end

        private

        def cause_of(event)
          event.respond_to?(:cause) ? event.cause.to_s : nil
        end

        def build(row)
          animal = @animals.find(row['animal_id'])
          return nil unless animal

          case row['type']
          when 'AnimalDied'
            Domain::Events::AnimalDied.new(animal: animal, cause: row['cause'].to_sym)
          when 'AnimalBorn'
            Domain::Events::AnimalBorn.new(animal: animal, sire_id: animal.parent_ids[0], dam_id: animal.parent_ids[1])
          when 'AnimalRenamed'
            Domain::Events::AnimalRenamed.new(animal: animal, old_name: animal.name.to_s, new_name: animal.name.to_s)
          end
        end
      end
    end
  end
end
