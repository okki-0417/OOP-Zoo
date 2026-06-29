# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AnimalRepository
        include Domain::Repositories::AnimalRepository

        def initialize(database, mapper: AnimalMapper.new)
          @database = database
          @mapper = mapper
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
          animal
        end

        def save_all(records)
          return records if records.empty?

          animals.insert_conflict(:replace).multi_insert(records.map { |animal| @mapper.to_row(animal) })
          records
        end

        def all
          animals.all.map { |row| @mapper.to_aggregate(row.transform_keys(&:to_s)) }
        end

        def all_deceased
          animals.exclude(death_cause: nil).all.map { |row| @mapper.to_aggregate(row.transform_keys(&:to_s)) }
        end

        private

        def animals
          @database.dataset(:animals)
        end
      end
    end
  end
end
