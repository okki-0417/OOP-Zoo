# frozen_string_literal: true

module Zoo
  module Domain
    class Enclosure
      include Shared::Entity

      attr_reader :id, :name, :temperature, :capacity, :cleanliness, :enrichment

      AREA_PER_SLOT_SQM = 100

      def initialize(name:, temperature:, capacity:, area_sqm: nil, climate_controlled: false,
                     id: Shared::Identifier.new)
        raise ArgumentError, 'エリア名は必須です' if name.to_s.empty?
        raise ArgumentError, '定員は1以上でなければなりません' unless capacity.is_a?(Integer) && capacity.positive?

        @id = id
        @name = name
        @temperature = temperature
        @capacity = capacity
        @area_sqm = area_sqm
        @climate_controlled = climate_controlled
        @cleanliness = Cleanliness.spotless
        @enrichment = Enrichment.stimulating
      end

      def climate_controlled?
        @climate_controlled
      end

      def effective_temperature(season)
        return @temperature if climate_controlled?

        season.felt_temperature(@temperature)
      end

      def self.reconstitute(id:, name:, temperature:, capacity:, cleanliness:)
        allocate.tap do |enclosure|
          enclosure.instance_variable_set(:@id, id)
          enclosure.instance_variable_set(:@name, name)
          enclosure.instance_variable_set(:@temperature, temperature)
          enclosure.instance_variable_set(:@capacity, capacity)
          enclosure.instance_variable_set(:@area_sqm, nil)
          enclosure.instance_variable_set(:@cleanliness, cleanliness)
          enclosure.instance_variable_set(:@enrichment, Enrichment.stimulating)
        end
      end

      def area_sqm
        @area_sqm || (capacity * AREA_PER_SLOT_SQM)
      end

      def clean(amount = 100)
        @cleanliness = @cleanliness.cleaned_by(amount)
        self
      end

      def soil(amount)
        @cleanliness = @cleanliness.soiled_by(amount)
        self
      end

      def filthy?
        @cleanliness.filthy?
      end

      def enrich(amount = 100)
        @enrichment = @enrichment.enriched_by(amount)
        self
      end

      def deplete_enrichment(amount)
        @enrichment = @enrichment.depleted_by(amount)
        self
      end

      def barren?
        @enrichment.barren?
      end
    end
  end
end
