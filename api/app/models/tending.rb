# frozen_string_literal: true

class Tending
  attr_reader :keeper, :enclosure

  def initialize(keeper:, enclosure:, occupancy:)
    @keeper = keeper
    @enclosure = enclosure
    @occupancy = occupancy
    freeze
  end

  def perform
    violation!
    @keeper.enclosures << @enclosure
    @keeper
  end

  def violation!
    errors = []
    errors << "飼育員#{@keeper.name}はすでに#{@enclosure.name}を担当しています" if @keeper.in_charge_of?(@enclosure)

    unqualified = occupant_taxa.reject { |taxon| @keeper.specialized_in?(taxon) }
    unless unqualified.empty?
      errors << "飼育員#{@keeper.name}は#{@enclosure.name}にいる#{unqualified.map(&:label).join('・')}を担当できません"
    end

    raise Errors::AssignmentNotAllowed, errors.join(', ') unless errors.empty?
  end

  def to_s
    "#{@keeper.name}を#{@enclosure.name}に配属"
  end

  private

  def occupant_taxa
    @occupancy.species_present_in.map(&:taxon_class).uniq
  end
end
