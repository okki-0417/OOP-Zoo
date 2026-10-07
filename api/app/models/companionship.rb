# frozen_string_literal: true

class Companionship
  SOCIAL_CONFLICT_INJURY = 5
  CROWDING_AGGRAVATION = 5
  NO_REFUGE_AGGRAVATION = 5

  def initialize(enclosure:, occupancy:, member:)
    @enclosure = enclosure
    @occupancy = occupancy
    @member = member
  end

  def lonely?
    return false unless @member.group_living?

    @occupancy.count { |other| other.alive? && other.species == @member.species } <= 1
  end

  def separated_dependent?
    return false if @member.weaned? || @member.parents.empty?

    @occupancy.none? { |other| other.alive? && @member.parents.include?(other) }
  end

  def subordinate_male?
    return false unless @member.contender?

    rivals = @occupancy.select { |other| other.contender? && other.species == @member.species }
    return false if rivals.size < 2

    @member != rivals.max_by(&:age_in_days)
  end

  def injury
    return 0 unless subordinate_male?

    SOCIAL_CONFLICT_INJURY +
      (@occupancy.overcrowded? ? CROWDING_AGGRAVATION : 0) +
      (@enclosure.barren? ? NO_REFUGE_AGGRAVATION : 0)
  end
end
