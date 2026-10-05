# frozen_string_literal: true

module Zoo
  module Domain
    class Rounding
      SOILED_THRESHOLD = 70
      DULL_THRESHOLD = 50

      Report = Data.define(:enclosure, :fed, :skipped, :cleaned, :enriched) do
        def cleaned? = cleaned
        def enriched? = enriched
      end

      def initialize(keeper:, occupancy:, assignment:, foods:)
        @keeper = keeper
        @occupancy = occupancy
        @assignment = assignment
        @foods = foods
      end

      def perform
        reject_unassigned!
        @skipped = []
        fed = feed_the_hungry
        cleaned = soiled? && !attempt(Cleaning, '勤務時間が足りず清掃できません').nil?
        enriched = dull? && !attempt(Enriching, '勤務時間が足りず遊具を補充できません').nil?
        Report.new(enclosure:, fed:, skipped: @skipped, cleaned:, enriched:)
      end

      private

      def enclosure
        @occupancy.enclosure
      end

      def reject_unassigned!
        return if @assignment.assigned?(@keeper.id)

        raise Errors::WorkNotAllowed, "飼育員#{@keeper.name}は#{enclosure.name}の担当ではありません"
      end

      def feed_the_hungry
        @occupancy.select { |animal| animal.alive? && animal.meals.variety.zero? }.each_with_object([]) do |animal, fed|
          next unless feedable?(animal)

          Feeding.new(keeper: @keeper, animal:, foods: Ration.new(animal:, foods: @foods).foods).serve
          fed << animal
        end
      end

      def feedable?(animal)
        unless @keeper.specialized_in?(animal.taxon_class)
          @skipped << [animal.name, '専門外のため給餌できません']
          return false
        end
        return true if @keeper.available_for?(Feeding::WORK_MINUTES)

        @skipped << [animal.name, '勤務時間が足りず給餌できません']
        false
      end

      def soiled?
        enclosure.cleanliness_level <= SOILED_THRESHOLD
      end

      def dull?
        enclosure.enrichment.level <= DULL_THRESHOLD
      end

      def attempt(work, reason_if_short)
        return work.new(keeper: @keeper, enclosure:).tap(&:perform) if @keeper.available_for?(work::WORK_MINUTES)

        note_skipped(reason_if_short)
        nil
      end

      def note_skipped(reason)
        @skipped << [enclosure.name, reason]
      end
    end
  end
end
