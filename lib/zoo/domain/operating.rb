# frozen_string_literal: true

module Zoo
  module Domain
    class Operating
      include Shared::Entity

      class NullOperating
        def total_visitors = 0
        def total_revenue  = Shared::Money.zero
      end

      attr_reader :id, :zoo, :day, :visitors, :income, :cost, :deaths, :balance,
                  :reputation, :outbreak, :total_visitors, :total_revenue

      def initialize(zoo:, occupancies:, keepers:, veterinarians:,
                     yesterday_operating: nil, random: Random.new,
                     id: Shared::Identifier.new)
        @zoo                 = zoo
        @occupancies         = occupancies
        @keepers             = keepers
        @veterinarians       = veterinarians
        @yesterday_operating = yesterday_operating
        @random              = random
        @id                  = id
        @dead                = []
        @afflicted           = nil
      end

      def self.reconstitute(id:, day:, visitors:, income:, cost:, deaths:, balance:,
                            reputation:, outbreak:, total_visitors:, total_revenue:)
        allocate.tap do |op|
          op.instance_variable_set(:@id,             id)
          op.instance_variable_set(:@day,            day)
          op.instance_variable_set(:@visitors,       visitors)
          op.instance_variable_set(:@income,         income)
          op.instance_variable_set(:@cost,           cost)
          op.instance_variable_set(:@deaths,         deaths)
          op.instance_variable_set(:@balance,        balance)
          op.instance_variable_set(:@reputation,     reputation)
          op.instance_variable_set(:@outbreak,       outbreak)
          op.instance_variable_set(:@total_visitors, total_visitors)
          op.instance_variable_set(:@total_revenue,  total_revenue)
        end
      end

      def operate_day
        on_exhibit      = @occupancies.flat_map(&:to_a)
        today_visitors  = VisitorAttraction.new(on_exhibit:, zoo: @zoo).expected_visitors
        @zoo.admit_visitors(today_visitors)

        @cost = OperatingCost.new(
          enclosures: @occupancies.map(&:enclosure),
          staff:      @keepers + @veterinarians,
          species:    on_exhibit.map(&:species).uniq
        ).amount
        @zoo.spend(@cost)

        @occupancies.each do |occupancy|
          Infestation.new(occupancy.enclosure, occupancy).spread
          Contagion.new(occupancy.enclosure, occupancy).spread
          occupancy.each do |animal|
            AnimalDay.new(animal:, enclosure: occupancy.enclosure, occupancy:, season: @zoo.season).run
          end
          occupancy.enclosure.soil(occupancy.count)
          occupancy.enclosure.deplete_enrichment

          @dead.concat(occupancy.select(&:dead?))
          @afflicted ||= SpontaneousInfection.new(occupancy, @random).strike
        end

        @zoo.update_reputation(
          @zoo.reputation.after_day(
            experience: Experience.new(on_exhibit:, fee: @zoo.admission_fee).score,
            exposure:   Exposure.new(visitors: today_visitors).score,
            events:     [
              *@dead.map { |animal| Zoo::NewsEvent.new(animal:) },
              (@afflicted ? Zoo::NewsEvent.new(afflicted: @afflicted) : nil)
            ].compact
          )
        )

        @zoo.advance_day
        snapshot!
        self
      end

      def enclosures
        @occupancies.map(&:enclosure)
      end

      def on_exhibit
        @occupancies.flat_map(&:to_a)
      end

      def net_income
        Shared::Balance.new(@income.yen - @cost.yen)
      end

      def to_s
        "#{@day}日目: 来園#{@visitors}人 純益#{net_income}"
      end

      private

      def snapshot!
        yesterday       = @yesterday_operating || NullOperating.new
        @day            = @zoo.day
        @deaths         = @dead.size
        @balance        = @zoo.balance
        @reputation     = @zoo.reputation_score
        @outbreak       = @afflicted&.name
        @total_visitors = @zoo.visitor_count
        @total_revenue  = @zoo.revenue
        @visitors       = @total_visitors - yesterday.total_visitors
        @income         = Shared::Money.yen(@total_revenue.yen - yesterday.total_revenue.yen)
      end
    end
  end
end
