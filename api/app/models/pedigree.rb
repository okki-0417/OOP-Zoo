# frozen_string_literal: true

class Pedigree
  def initialize
    @coancestry = {}
  end

  def coancestry(one, other)
    return 0.0 if one.nil? || other.nil?

    @coancestry[Set[one, other]] ||= compute_coancestry(one, other)
  end

  def inbreeding_of(animal)
    parents = animal.parents
    return 0.0 if parents.size < 2

    coancestry(parents[0], parents[1])
  end

  def related?(one, other)
    other.parents.include?(one) || one.parents.include?(other) || one.parents.intersect?(other.parents)
  end

  def mean_kinship(animals)
    pairs = animals.combination(2).to_a
    return 0.0 if pairs.empty?

    pairs.sum { |one, other| coancestry(one, other) } / pairs.size
  end

  private

  def compute_coancestry(one, other)
    return 0.5 * (1.0 + inbreeding_of(one)) if one == other
    return compute_coancestry(other, one) if one.age_in_days > other.age_in_days

    parents = one.parents
    return 0.0 if parents.empty?

    0.5 * parents.sum { |parent| coancestry(parent, other) }
  end
end
