# frozen_string_literal: true

module Zoo
  module Domain
    class ReputationEvaluation
      FEE_PER_EXPECTATION = 500

      def initialize(reputation:, admission_fee:, on_exhibit:, visitors:, dead:, afflicted:)
        @reputation = reputation
        @admission_fee = admission_fee
        @on_exhibit = on_exhibit
        @visitors = visitors
        @dead = dead
        @afflicted = afflicted
      end

      def evaluated
        @reputation.after_day(experience: experience, exposure: exposure, events: events)
      end

      private

      def experience
        (ExhibitCondition.new(@on_exhibit).score - (@admission_fee.yen / FEE_PER_EXPECTATION)).clamp(0, 100)
      end

      def exposure
        @visitors
      end

      def events
        news = @dead.map { |animal| ReputationEvent::Death.new(cause: :unknown, charisma: animal.charisma) }
        news << ReputationEvent::Outbreak.new if @afflicted
        news
      end
    end
  end
end
