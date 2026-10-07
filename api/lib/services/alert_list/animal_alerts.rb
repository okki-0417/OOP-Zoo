# frozen_string_literal: true

module Services
  class AlertList
    class AnimalAlerts
      STARVATION_WARNING_DAYS = 2

      def initialize(animal:, occupancy:, season:)
        @animal = animal
        @occupancy = occupancy
        @season = season
      end

      def to_a
        [
          prognosis_alert, hunger_alert, illness_alert, malnourished_alert,
          stress_alert, climate_alert, delivery_alert
        ].compact
      end

      private

      def alert(severity, kind, message)
        { severity:, kind:, subject_type: :animal, subject: @animal, message: }
      end

      def prognosis_alert
        prognosis = ::Prognosis.new(
          animal: @animal, enclosure: @occupancy.enclosure, occupancy: @occupancy, season: @season
        )
        return if prognosis.outlook == :good

        alert(
          prognosis.outlook == :grave ? :critical : :warning, prognosis.outlook,
          "このままだと#{prognosis.days_to_death}日以内に#{prognosis.cause_of_death_label}する見込みです"
        )
      end

      def hunger_alert
        if @animal.starving?
          alert(:critical, :starving, '飢餓状態です。体力が日々削られています')
        elsif @animal.days_until_starving <= STARVATION_WARNING_DAYS
          alert(:warning, :hungry, "#{@animal.days_until_starving}日で飢餓に陥ります")
        end
      end

      def illness_alert
        return unless @animal.sick?

        spreading = @animal.contagious? && @occupancy.any? { |other| other != @animal && other.susceptible? }
        alert(:warning, :sick,
              "#{@animal.illness_name}にかかっています#{'。同居個体にうつるおそれがあります' if spreading}")
      end

      def malnourished_alert
        alert(:warning, :malnourished, '栄養失調です。餌の種類が足りていません') if @animal.malnourished?
      end

      def stress_alert
        if @animal.severely_stressed?
          alert(:warning, :stressed, '強いストレスで体力を削られています')
        elsif @animal.stressed?
          alert(:notice, :stressed, 'ストレスを抱えています')
        end
      end

      def climate_alert
        enclosure = @occupancy.enclosure
        temperature = enclosure.effective_temperature(@season)
        suitability = ::ThermalSuitability.new(@animal, temperature)
        return if suitability.comfortable?

        habitable = suitability.habitable?
        alert(habitable ? :notice : :warning, :climate,
              "#{enclosure.name}の体感#{temperature}は#{habitable ? '快適域から外れています' : '生存可能域の外です'}")
      end

      def delivery_alert
        alert(:notice, :due, '出産(孵化)の時期を迎えています') if @animal.ready_to_deliver?
      end
    end
  end
end
