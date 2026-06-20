# frozen_string_literal: true

module Zoo
  module Domain
    module MatingRecommendation
      module_function

      def recommend(animals, births)
        pedigree = Pedigree.new(births)
        candidate_pairs(animals, pedigree)
          .min_by { |sire, dam| pedigree.coancestry(sire, dam) }
      end

      def candidate_pairs(animals, pedigree = Pedigree.new)
        males = animals.select(&:male?)
        females = animals.select(&:female?)
        males.product(females).select do |sire, dam|
          sire.can_breed_with?(dam) && !pedigree.related?(sire, dam)
        end
      end
    end
  end
end
