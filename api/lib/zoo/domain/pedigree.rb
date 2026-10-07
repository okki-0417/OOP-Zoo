# frozen_string_literal: true

module Zoo
  module Domain
    class Pedigree
      def initialize
        @coancestry = {}
      end

      def coancestry(a, b)
        return 0.0 if a.nil? || b.nil?

        @coancestry[Set[a, b]] ||= compute_coancestry(a, b)
      end

      def inbreeding_of(animal)
        parents = animal.parents
        return 0.0 if parents.size < 2

        coancestry(parents[0], parents[1])
      end

      def related?(a, b)
        b.parents.include?(a) || a.parents.include?(b) || a.parents.intersect?(b.parents)
      end

      def mean_kinship(animals)
        pairs = animals.combination(2).to_a
        return 0.0 if pairs.empty?

        pairs.sum { |a, b| coancestry(a, b) } / pairs.size
      end

      private

      def compute_coancestry(a, b)
        return 0.5 * (1.0 + inbreeding_of(a)) if a == b
        return compute_coancestry(b, a) if a.age_in_days > b.age_in_days

        parents = a.parents
        return 0.0 if parents.empty?

        0.5 * parents.sum { |parent| coancestry(parent, b) }
      end
    end
  end
end
