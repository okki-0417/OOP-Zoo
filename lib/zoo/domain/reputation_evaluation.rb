# frozen_string_literal: true

module Zoo
  module Domain
    class ReputationEvaluation
      CONDITION_NEUTRAL = 50
      FEE_PER_EXPECTATION = 500

      def initialize(admission_fee:, on_exhibit:, visitors:, dead:, afflicted:)
        @admission_fee = admission_fee
        @on_exhibit = on_exhibit
        @visitors = visitors
        @dead = dead
        @afflicted = afflicted
      end

      def experience
        (exhibit_condition - (@admission_fee.yen / FEE_PER_EXPECTATION)).clamp(0, 100)
      end

      def exposure
        @visitors
      end

      def events
        news = @dead.map { |animal| ReputationEvent::Death.new(cause: :unknown, charisma: animal.charisma) }
        news << ReputationEvent::Outbreak.new if @afflicted
        news
      end

      private

      def exhibit_condition
        living = @on_exhibit.select(&:alive?)
        return CONDITION_NEUTRAL if living.empty?

        living.sum(&:visible_condition) / living.size
      end
    end
  end
end
