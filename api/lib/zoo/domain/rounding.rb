# frozen_string_literal: true

module Zoo
  module Domain
    class Rounding
      Report = Data.define(:enclosure, :fed, :skipped, :cleaned, :enriched) do
        def cleaned? = cleaned
        def enriched? = enriched
      end

      def initialize(keeper:, occupancy:, foods:)
        @keeper = keeper
        @occupancy = occupancy
        @foods = foods
      end

      def perform
        reject_unassigned!
        @skipped = []
        fed = feed_the_hungry
        cleaned = enclosure.soiled? && !attempt(Cleaning, '勤務時間が足りず清掃できません').nil?
        enriched = enclosure.dull? && !attempt(Enriching, '勤務時間が足りず遊具を補充できません').nil?
        Report.new(enclosure:, fed:, skipped: @skipped, cleaned:, enriched:)
      end

      private

      def enclosure
        @occupancy.enclosure
      end

      def reject_unassigned!
        return if @keeper.in_charge_of?(enclosure)

        raise Errors::WorkNotAllowed, "飼育員#{@keeper.name}は#{enclosure.name}の担当ではありません"
      end

      def feed_the_hungry
        @occupancy.select { |animal| animal.alive? && !animal.fed_today? }.each_with_object([]) do |animal, fed|
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
