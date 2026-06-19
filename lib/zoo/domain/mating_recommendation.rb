# frozen_string_literal: true

module Zoo
  module Domain
    module MatingRecommendation
      module_function

      def recommend(animals, lookup)
        candidate_pairs(animals)
          .min_by { |sire, dam| dam.inbreeding_of_offspring_with(sire, lookup) }
      end

      def candidate_pairs(animals)
        males = animals.select { |a| a.sex.male? }
        females = animals.select { |a| a.sex.female? }

        males.product(females).select { |sire, dam| sire.can_mate_with?(dam) }
      end
    end
  end
end
