# frozen_string_literal: true

class ZooDay
  attr_reader :zoo

  def initialize(zoo:, occupancies:, keepers:, veterinarians:, yesterday: nil, random: Random.new)
    @zoo           = zoo
    @occupancies   = occupancies
    @keepers       = keepers
    @veterinarians = veterinarians
    @yesterday     = yesterday || Operating.none_yet
    @random        = random
    @dead          = []
    @afflicted     = nil
  end

  def run
    today_visitors = VisitorAttraction.new(on_exhibit:, zoo: @zoo).expected_visitors
    @zoo.admit_visitors(today_visitors)

    operating_cost = OperatingCost.new(enclosures:, staff: @keepers + @veterinarians,
                                       species: on_exhibit.map(&:species))
    @zoo.spend(operating_cost.amount)

    @occupancies.each { |occupancy| pass_day_in(occupancy) }

    @zoo.update_reputation(
      @zoo.reputation.after_day(
        experience: Experience.new(on_exhibit:, fee: @zoo.admission_fee).score,
        exposure: Exposure.new(visitors: today_visitors).score,
        events: news
      )
    )

    @keepers.each(&:end_shift)
    @zoo.advance_day
    record(operating_cost)
  end

  def enclosures
    @occupancies.map(&:enclosure)
  end

  def casualties
    @dead.dup
  end

  def keepers
    @keepers.dup
  end

  def on_exhibit
    @occupancies.flat_map(&:to_a)
  end

  private

  def pass_day_in(occupancy)
    Infestation.new(occupancy.enclosure, occupancy).spread
    Contagion.new(occupancy.enclosure, occupancy, random: @random).spread
    occupancy.each do |animal|
      AnimalDay.new(animal:, enclosure: occupancy.enclosure, occupancy:, season: @zoo.season).run
    end
    occupancy.enclosure.soil(occupancy.count)
    occupancy.enclosure.deplete_enrichment

    @dead.concat(occupancy.select(&:dead?))
    strike_spontaneous_infection(occupancy)
  end

  def strike_spontaneous_infection(occupancy)
    return if @afflicted

    @afflicted = SpontaneousInfection.new(occupancy, @random).strike
  end

  def news
    [
      *@dead.map { |animal| Zoo::NewsEvent.new(animal:) },
      (@afflicted ? Zoo::NewsEvent.new(afflicted: @afflicted) : nil)
    ].compact
  end

  def record(operating_cost)
    Operating.new(
      day: @zoo.day,
      visitors: @zoo.visitor_count - @yesterday.total_visitors,
      income: Money.yen(@zoo.revenue.yen - @yesterday.total_revenue.yen),
      cost: operating_cost.amount,
      expenses: operating_cost.expenses,
      deaths: @dead.size,
      balance: @zoo.balance,
      reputation: @zoo.reputation_score,
      outbreak: @afflicted&.name,
      total_visitors: @zoo.visitor_count,
      total_revenue: @zoo.revenue,
      casualties: @dead.dup
    )
  end
end
