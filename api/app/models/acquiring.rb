# frozen_string_literal: true

class Acquiring < ApplicationRecord
  CONSERVATION_REPUTATION_GAIN = 5
  ACQUIRED_HEALTH = 100

  belongs_to :zoo, inverse_of: :acquirings
  belongs_to :animal

  attribute :cost, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)

  def perform
    animal.zoo = zoo
    self.day = zoo.day
    self.cost = animal.tradeable? ? animal.acquisition_price : Money.zero
    zoo.authorize_payment(cost)
    zoo.gain_reputation(CONSERVATION_REPUTATION_GAIN) unless animal.tradeable?
    zoo.save!
    animal.save!
    save!
    animal
  end
end
