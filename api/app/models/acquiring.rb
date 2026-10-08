# frozen_string_literal: true

class Acquiring
  CONSERVATION_REPUTATION_GAIN = 5
  ACQUIRED_HEALTH = 100

  def initialize(zoo:, animal:)
    @zoo = zoo
    @animal = animal
  end

  def perform
    if @animal.tradeable?
      @zoo.purchase(@animal.acquisition_price)
    else
      @zoo.gain_reputation(CONSERVATION_REPUTATION_GAIN)
    end
    @zoo.save!
    @animal.save!
    @animal
  end
end
