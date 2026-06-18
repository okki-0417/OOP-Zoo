# frozen_string_literal: true

module Zoo
  module Domain
    module ReputationEvent
      class Death
        BASE_PENALTY = 5
        PREVENTABLE_MULTIPLIER = 2
        CHARISMA_PIVOT = 50

        PREVENTABLE_CAUSES = %i[starvation neglect].freeze

        def initialize(cause:, charisma:)
          @cause = cause
          @charisma = charisma
        end

        def reputation_delta
          weight = PREVENTABLE_CAUSES.include?(@cause) ? PREVENTABLE_MULTIPLIER : 1
          -(BASE_PENALTY * weight * @charisma / CHARISMA_PIVOT.to_f).round
        end
      end

      class Outbreak
        PENALTY = 8

        def reputation_delta
          -PENALTY
        end
      end

      class ConservationBreeding
        REPUTATION_GAIN = 4

        def self.for(species)
          return nil unless species.conservation_status.threatened?

          new(species)
        end

        def initialize(species)
          @species = species
        end

        def reputation_delta
          REPUTATION_GAIN
        end
      end
    end
  end
end
