# frozen_string_literal: true

class Constructing
  def initialize(zoo:, enclosure:)
    @zoo = zoo
    @enclosure = enclosure
  end

  def perform
    @zoo.purchase(Enclosure.construction_cost(capacity: @enclosure.capacity,
                                              climate_controlled: @enclosure.climate_controlled))
    @zoo.save!
    @enclosure.save!
    @enclosure
  end

  def to_s
    "#{@enclosure.name}を建設"
  end
end
