# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      module VisitorAttraction
        module_function

        WILLINGNESS_BASE_YEN = 3_000
        WILLINGNESS_PER_APPEAL_YEN = 15

        def expected_visitors(animals, reputation, admission_fee, buzz: 0)
          return 0 if animals.empty?

          appeal = appeal_of(animals, buzz)
          q_max = max_demand(appeal, reputation)
          p_max = willingness_to_pay(appeal, reputation)
          price = admission_fee.yen
          return 0 if price >= p_max

          (q_max * (1.0 - (price.to_f / p_max))).to_i
        end

        def appeal_of(animals, buzz = 0)
          species = animals.map(&:species).uniq
          species.sum(&:charisma) + buzz
        end

        def max_demand(appeal, reputation)
          appeal * reputation.score / Reputation::MAX
        end

        def willingness_to_pay(appeal, reputation)
          WILLINGNESS_BASE_YEN + (appeal * WILLINGNESS_PER_APPEAL_YEN * reputation.score / Reputation::MAX)
        end
      end
    end
  end
end
