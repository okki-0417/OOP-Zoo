# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Pedigree
        include Shared::ValueObject

        attr_reader :parent_ids

        def initialize(animal_id, parent_ids, age_in_days)
          @animal_id  = animal_id
          @parent_ids = parent_ids
          @age_in_days = age_in_days
          freeze
        end

        def kinship_with(other, lookup)
          return 0.0 if other.nil?
          return 0.5 * (1.0 + inbreeding_coefficient(lookup)) if @animal_id == other.animal_id
          return other.kinship_with(self, lookup) if @age_in_days > other.age_in_days

          parents = parent_pedigrees(lookup)
          return 0.0 if parents.empty?

          0.5 * parents.sum { |parent| parent.kinship_with(other, lookup) }
        end

        def inbreeding_coefficient(lookup)
          parents = parent_pedigrees(lookup)
          return 0.0 if parents.size < 2

          parents[0].kinship_with(parents[1], lookup)
        end

        protected

        attr_reader :animal_id, :age_in_days

        def components
          [@animal_id, @parent_ids]
        end

        private

        def parent_pedigrees(lookup)
          @parent_ids.map { |id| lookup.call(id)&.pedigree }.compact
        end
      end
    end
  end
end
