# frozen_string_literal: true

module Zoo
  module Domain
    class Enclosure < ApplicationRecord
      AREA_PER_SLOT_SQM = 100
      ENRICHMENT_DECAY_PER_DAY = 2

      CONSTRUCTION_BASE_YEN = 30_000
      CONSTRUCTION_PER_SLOT_YEN = 10_000
      CLIMATE_CONTROL_SURCHARGE_YEN = 50_000

      UPKEEP_YEN = 5_000
      CLIMATE_CONTROL_RUNNING_YEN = 4_000

      has_many :animals, -> { order(:id) }, inverse_of: :enclosure
      has_many :assignments, dependent: :destroy
      has_many :keepers, -> { order(:id) }, through: :assignments

      attribute :temperature, Shared::ValueType.new(Shared::Temperature, dump: :celsius.to_proc)
      attribute :cleanliness, Shared::ValueType.new(Cleanliness, dump: :level.to_proc),
                default: -> { Cleanliness.spotless }
      attribute :enrichment, Shared::ValueType.new(Enrichment, dump: :level.to_proc),
                default: -> { Enrichment.stimulating }

      validates :name, presence: { message: 'エリア名は必須です' }
      validates :capacity, numericality: { only_integer: true, greater_than: 0, message: '定員は1以上でなければなりません' }

      def self.construction_cost(capacity:, climate_controlled: false)
        yen = CONSTRUCTION_BASE_YEN + (CONSTRUCTION_PER_SLOT_YEN * capacity)
        yen += CLIMATE_CONTROL_SURCHARGE_YEN if climate_controlled
        Shared::Money.yen(yen)
      end

      def daily_upkeep
        Shared::Money.yen(UPKEEP_YEN + (climate_controlled? ? CLIMATE_CONTROL_RUNNING_YEN : 0))
      end

      def effective_temperature(season)
        return temperature if climate_controlled?

        season.felt_temperature(temperature)
      end

      def area_sqm
        super || (capacity * AREA_PER_SLOT_SQM)
      end

      def clean(amount = 100)
        self.cleanliness = cleanliness.cleaned_by(amount)
        self
      end

      def soil(amount)
        self.cleanliness = cleanliness.soiled_by(amount)
        self
      end

      def filthy?
        cleanliness.filthy?
      end

      def soiled?
        cleanliness.soiled?
      end

      def cleanliness_level
        cleanliness.level
      end

      def enrich(amount = 100)
        self.enrichment = enrichment.enriched_by(amount)
        self
      end

      def deplete_enrichment(amount = ENRICHMENT_DECAY_PER_DAY)
        self.enrichment = enrichment.depleted_by(amount)
        self
      end

      def barren?
        enrichment.barren?
      end

      def dull?
        enrichment.dull?
      end
    end
  end
end
