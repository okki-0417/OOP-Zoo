# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      module VisitorAttraction
        module_function

        WILLINGNESS_BASE_YEN = 3_000
        WILLINGNESS_PER_SPECTACLE_YEN = 15

        def expected_visitors(animals, reputation, admission_fee, buzz: 0)
          return 0 if animals.empty?

          spectacle = spectacle_of(animals, buzz)
          q_max = max_demand(spectacle, reputation)
          p_max = willingness_to_pay(spectacle, reputation)
          price = admission_fee.yen
          return 0 if price >= p_max

          (q_max * (1.0 - (price.to_f / p_max))).to_i
        end

        def spectacle_of(animals, buzz = 0)
          species = animals.map(&:species).uniq
          species.sum(&:charisma) + buzz
        end

        def max_demand(spectacle, reputation)
          spectacle * reputation.score / Reputation::MAX
        end

        def willingness_to_pay(spectacle, reputation)
          WILLINGNESS_BASE_YEN + (spectacle * WILLINGNESS_PER_SPECTACLE_YEN * reputation.score / Reputation::MAX)
        end
      end
    end
  end
end
