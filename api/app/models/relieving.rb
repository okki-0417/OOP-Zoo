# frozen_string_literal: true

class Relieving
  attr_reader :keeper, :enclosure

  def initialize(keeper:, enclosure:)
    @keeper = keeper
    @enclosure = enclosure
    freeze
  end

  def perform
    violation!
    @keeper.enclosures.delete(@enclosure)
    @keeper
  end

  def violation!
    return if @keeper.in_charge_of?(@enclosure)

    raise Errors::ReliefNotAllowed,
          "飼育員#{@keeper.name}は#{@enclosure.name}を担当していないため退任できません"
  end

  def to_s
    "#{@keeper.name}を#{@enclosure.name}の担当から外す"
  end
end
