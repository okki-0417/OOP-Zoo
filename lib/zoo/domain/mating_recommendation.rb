# frozen_string_literal: true

module Zoo
  module Domain
    module MatingRecommendation
      module_function

      def recommend(animals, lookup)
        candidate_pairs(animals)
          .min_by { |sire, dam| Pedigree.inbreeding_of_offspring(sire, dam, lookup) }
      end

      def candidate_pairs(animals)
        males = animals.select { |a| a.sex.male? }
        females = animals.select { |a| a.sex.female? }

        males.product(females).select { |sire, dam| BreedingPolicy.can_mate?(sire, dam) }
      end
    end
  end
end
