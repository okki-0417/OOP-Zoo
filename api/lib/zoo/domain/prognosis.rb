# frozen_string_literal: true

module Zoo
  module Domain
    class Prognosis
      HORIZON_DAYS = 30
      GRAVE_DAYS = 3
      GUARDED_DAYS = 14

      Course = Data.define(:days_to_death, :cause_of_death)

      def initialize(animal:, enclosure:, occupancy:, season:)
        @animal = animal
        @enclosure = enclosure
        @occupancy = occupancy
        @season = season
      end

      def days_to_death
        course.days_to_death
      end

      def cause_of_death
        course.cause_of_death
      end

      def cause_of_death_label
        cause_of_death && Animal::Death.new(cause: cause_of_death).to_s
      end

      def outlook
        return :good if days_to_death.nil?
        return :grave if days_to_death <= GRAVE_DAYS
        return :guarded if days_to_death <= GUARDED_DAYS

        :good
      end

      private

      def course
        @course ||= project
      end

      def project
        return Course.new(days_to_death: nil, cause_of_death: nil) if @animal.dead?

        animal = @animal.dup
        enclosure = @enclosure.dup
        (1..HORIZON_DAYS).each do |day|
          live_through_a_day(animal, enclosure)
          return Course.new(days_to_death: day, cause_of_death: animal.cause_of_death) if animal.dead?
        end
        Course.new(days_to_death: nil, cause_of_death: nil)
      end

      def live_through_a_day(animal, enclosure)
        animal.satisfy_hunger(Animal::Hunger::MAX)
        animal.take_meal(animal.acceptable_food_categories)
        Infestation.new(enclosure, [animal]).spread
        AnimalDay.new(animal:, enclosure:, occupancy: @occupancy, season: @season).run
        enclosure.soil(@occupancy.count)
        enclosure.deplete_enrichment
      end
    end
  end
end
