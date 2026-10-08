# frozen_string_literal: true

class Buzz
  NEWBORN_SHARE = 0.5
  NEWBORN_DAYS = 30
  NEWCOMER_SHARE = 0.25
  NEWCOMER_DAYS = 7

  attr_reader :animal

  def initialize(animal:, today:)
    @animal = animal
    @today = today
  end

  def kind
    if newborn?
      :newborn
    elsif newcomer?
      :newcomer
    end
  end

  def amount
    case kind
    when :newborn then fading(NEWBORN_SHARE, @animal.age_in_days, NEWBORN_DAYS)
    when :newcomer then fading(NEWCOMER_SHARE, days_since_arrival, NEWCOMER_DAYS)
    else 0.0
    end
  end

  private

  def newborn?
    @animal.dam.present? && @animal.age_in_days < NEWBORN_DAYS
  end

  def newcomer?
    @animal.acquiring.present? && days_since_arrival < NEWCOMER_DAYS
  end

  def days_since_arrival
    @today - @animal.acquiring.day
  end

  def fading(share, elapsed, period)
    @animal.species.charisma * share * (1 - (elapsed / period.to_f))
  end
end
