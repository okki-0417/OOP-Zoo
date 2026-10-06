# frozen_string_literal: true

module Zoo
  module Domain
    class Pedigree
      def initialize(births = [])
        @parents_of = births.to_h { |birth| [birth.offspring.id, birth.parents] }
        @coancestry = {}
      end

      def coancestry(a, b)
        return 0.0 if a.nil? || b.nil?

        @coancestry[pair_key(a, b)] ||= compute_coancestry(a, b)
      end

      def inbreeding_of(animal)
        parents = parents_of(animal)
        return 0.0 if parents.size < 2

        coancestry(parents[0], parents[1])
      end

      def related?(a, b)
        a_parents = parent_ids_of(a)
        b_parents = parent_ids_of(b)
        b_parents.include?(a.id) ||
          a_parents.include?(b.id) ||
          a_parents.intersect?(b_parents)
      end

      def mean_kinship(animals)
        pairs = animals.combination(2).to_a
        return 0.0 if pairs.empty?

        pairs.sum { |a, b| coancestry(a, b) } / pairs.size
      end

      private

      def compute_coancestry(a, b)
        return 0.5 * (1.0 + inbreeding_of(a)) if a.id == b.id
        return compute_coancestry(b, a) if a.age_in_days > b.age_in_days

        parents = parents_of(a)
        return 0.0 if parents.empty?

        0.5 * parents.sum { |parent| coancestry(parent, b) }
      end

      def parents_of(animal)
        @parents_of[animal.id] || []
      end

      def parent_ids_of(animal)
        parents_of(animal).map(&:id)
      end

      def pair_key(a, b)
        [a.id.to_s, b.id.to_s].sort
      end
    end
  end
end
