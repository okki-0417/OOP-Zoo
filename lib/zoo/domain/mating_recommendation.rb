# frozen_string_literal: true

module Zoo
  module Domain
    module MatingRecommendation
      module_function

      def recommend(animals, parents)
        candidate_pairs(animals)
          .min_by { |sire, dam| Breeding.kinship(sire, dam, parents) }
      end

      def candidate_pairs(animals)
        males = animals.select(&:male?)
        females = animals.select(&:female?)
        males.product(females).select do |sire, dam|
          sire.can_breed_with?(dam) && !Breeding.new(sire:, dam:).related?
        end
      end
    end
  end
end
