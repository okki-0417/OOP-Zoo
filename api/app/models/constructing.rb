# frozen_string_literal: true

class Constructing < ApplicationRecord
  belongs_to :zoo, inverse_of: :constructings
  belongs_to :enclosure

  attribute :cost, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)

  def perform
    enclosure.zoo = zoo
    self.day = zoo.day
    self.cost = Enclosure.construction_cost(capacity: enclosure.capacity, climate_controlled: enclosure.climate_controlled)
    zoo.authorize_payment(cost)
    enclosure.save!
    save!
    enclosure
  end

  def to_s
    "#{enclosure.name}を建設"
  end
end
