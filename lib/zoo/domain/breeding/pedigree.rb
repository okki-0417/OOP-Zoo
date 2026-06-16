# frozen_string_literal: true

module Zoo
  module Domain
    module Breeding
      module Pedigree
        module_function

        def kinship(a, b, lookup)
          return 0.0 if a.nil? || b.nil?
          return 0.5 * (1.0 + inbreeding_coefficient(a, lookup)) if a.id == b.id

          younger, other = order_by_age(a, b)
          parents = parents_of(younger, lookup)
          return 0.0 if parents.empty?

          0.5 * parents.sum { |parent| kinship(parent, other, lookup) }
        end

        def inbreeding_coefficient(animal, lookup)
          parents = parents_of(animal, lookup)
          return 0.0 if parents.size < 2

          kinship(parents[0], parents[1], lookup)
        end

        def inbreeding_of_offspring(sire, dam, lookup)
          kinship(sire, dam, lookup)
        end

        def mean_kinship(animals, lookup)
          pairs = animals.combination(2).to_a
          return 0.0 if pairs.empty?

          pairs.sum { |a, b| kinship(a, b, lookup) } / pairs.size
        end

        def parents_of(animal, lookup)
          animal.parent_ids.map { |id| lookup.call(id) }.compact
        end

        def order_by_age(a, b)
          a.age_in_days.value <= b.age_in_days.value ? [a, b] : [b, a]
        end
      end
    end
  end
end
