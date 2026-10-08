# frozen_string_literal: true

class Acquiring < ApplicationRecord
  ACQUIRED_HEALTH = 100

  belongs_to :zoo, inverse_of: :acquirings
  belongs_to :animal

  attribute :cost, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)

  def perform
    animal.zoo = zoo
    self.day = zoo.day
    self.cost = animal.tradeable? ? animal.acquisition_price : Money.zero
    zoo.authorize_payment(cost)
    animal.save!
    save!
    animal
  end

  def conservation?
    !animal.tradeable?
  end
end
