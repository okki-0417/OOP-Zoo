# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AnimalRepository
        include Domain::Repositories::AnimalRepository

        def initialize(database, mapper: AnimalMapper.new, naming_mapper: NamingMapper.new)
          @database = database
          @mapper = mapper
          @naming_mapper = naming_mapper
        end

        def find(id)
          row = animals.where(id: id.to_s).first
          row && @mapper.to_aggregate(row.transform_keys(&:to_s))
        end

        def find_all(ids)
          keys = ids.map(&:to_s).uniq
          return {} if keys.empty?

          animals.where(id: keys).each_with_object({}) do |row, found|
            animal = @mapper.to_aggregate(row.transform_keys(&:to_s))
            found[animal.id.to_s] = animal
          end
        end

        def save(animal)
          animals.insert_conflict(:replace).insert(@mapper.to_row(animal))
          animal.recorded_events.grep(Domain::Events::AnimalNamed).each { |event| append_naming(event) }
          animal
        end

        def all
          animals.all.map { |row| @mapper.to_aggregate(row.transform_keys(&:to_s)) }
        end

        def namings
          naming_events.order(:id).all.map { |row| row.transform_keys(&:to_s) }
        end

        private

        def animals
          @database.dataset(:animals)
        end

        def naming_events
          @database.dataset(:namings)
        end

        def append_naming(event)
          naming_events.insert(@naming_mapper.to_row(event))
        end
      end
    end
  end
end
