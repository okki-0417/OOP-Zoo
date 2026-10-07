# frozen_string_literal: true

class Cleaning
  WORK_MINUTES = 60

  attr_reader :keeper, :enclosure

  def initialize(keeper:, enclosure:, amount: 100)
    @keeper = keeper
    @enclosure = enclosure
    @amount = amount
    freeze
  end

  def perform
    @keeper.clock_in(WORK_MINUTES)
    @enclosure.clean(@amount)
  end

  def to_s
    "#{@keeper.name}が#{@enclosure.name}を清掃"
  end
end
