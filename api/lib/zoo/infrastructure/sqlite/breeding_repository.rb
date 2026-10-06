# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BreedingRepository
        include Domain::Repositories::BreedingRepository

        def initialize(database, animals, mapper: BreedingMapper.new)
          @database = database
          @animals = animals
          @mapper = mapper
        end

        def save(breeding)
          breedings.insert_conflict(:replace).insert(@mapper.to_row(breeding))
          breeding
        end

        def all
          build_breedings(breedings.order(:rowid).all)
        end

        def for_dam(dam_id)
          row = breedings.where(dam_id: dam_id.to_s).order(Sequel.desc(:rowid)).first
          build_breedings([row].compact).first
        end

        private

        def breedings
          @database.dataset(:breedings)
        end

        def build_breedings(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          lookup = animal_lookup(rows, 'sire_id', 'dam_id')
          rows.filter_map { |row| @mapper.to_aggregate(row, lookup) }
        end

        def animal_lookup(rows, *columns)
          animals = @animals.find_all(rows.flat_map { |row| columns.map { |column| row[column] } }.compact)
          ->(id) { animals[id.to_s] }
        end
      end
    end
  end
end
