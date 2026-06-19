# frozen_string_literal: true

module Zoo
  module Domain
    module ReputationEvaluation
      module_function

      CONDITION_NEUTRAL = 50
      FEE_PER_EXPECTATION = 500

      def evaluate(zoo:, on_exhibit:, visitors:, dead:, afflicted:)
        experience = visitor_experience(zoo.admission_fee, exhibit_condition(on_exhibit))
        exposure = visitors
        events = reputation_news(dead, afflicted)

        zoo.update_reputation(experience:, exposure:, events:)
      end

      def exhibit_condition(animals)
        living = animals.select(&:alive?)
        return CONDITION_NEUTRAL if living.empty?

        living.sum(&:visible_condition) / living.size
      end

      def visitor_experience(fee, condition)
        (condition - (fee.yen / FEE_PER_EXPECTATION)).clamp(0, 100)
      end

      def reputation_news(dead, afflicted)
        events = dead.map { |a| ReputationEvent::Death.new(cause: :unknown, charisma: a.species.charisma) }
        events << ReputationEvent::Outbreak.new if afflicted
        events
      end
    end
  end
end
