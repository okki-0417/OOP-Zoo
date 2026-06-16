# frozen_string_literal: true

module Zoo
  module Domain
    module Taxonomy
      class Species
        include Shared::ValueObject

        attr_reader :name_ja, :scientific_name, :taxon_class, :diet_type,
                    :conservation_status, :habitable_temperature_range,
                    :lifespan_years, :maturity_age_years, :gestation_period_days,
                    :adult_weight, :default_voice, :litter_size, :breeding_season, :charisma

        YEAR_ROUND = :year_round

        def initialize(name_ja:, scientific_name:, taxon_class:, diet_type:,
                       conservation_status:, habitable_temperature_range:,
                       lifespan_years:, maturity_age_years:, gestation_period_days:,
                       adult_weight:, default_voice: nil, group_living: false,
                       litter_size: 1, breeding_season: YEAR_ROUND, charisma: 40)
          raise ArgumentError, '和名は必須です' if name_ja.to_s.empty?
          raise ArgumentError, '学名は必須です' if scientific_name.to_s.empty?
          raise ArgumentError, '産仔数は1以上でなければなりません' unless litter_size.is_a?(Integer) && litter_size.positive?

          @name_ja = name_ja
          @scientific_name = scientific_name
          @taxon_class = taxon_class
          @diet_type = diet_type
          @conservation_status = conservation_status
          @habitable_temperature_range = habitable_temperature_range
          @lifespan_years = lifespan_years
          @maturity_age_years = maturity_age_years
          @gestation_period_days = gestation_period_days
          @adult_weight = adult_weight
          @default_voice = default_voice
          @group_living = group_living
          @litter_size = litter_size
          @breeding_season = breeding_season
          @charisma = charisma
          freeze
        end

        def breeds_year_round?
          @breeding_season == YEAR_ROUND
        end

        def breeds_in?(season)
          breeds_year_round? || season.value == @breeding_season
        end

        def reproductively_senesces?
          @taxon_class.warm_blooded?
        end

        def predatory?
          @diet_type.predatory?
        end

        def tradeable?
          !@conservation_status.threatened? && !@conservation_status.extinct?
        end

        SPACE_SQM_PER_KG = 0.25
        MIN_SPACE_SQM = 5

        WIDE_RANGING_FACTOR = 2.0
        AQUATIC_FACTOR = 1.5
        FLIGHTED_FACTOR = 1.5

        def wide_ranging?
          @taxon_class.value == :mammal && predatory?
        end

        def aquatic?
          @taxon_class.value == :fish
        end

        def flighted?
          @taxon_class.value == :bird
        end

        def ranging_factor
          return WIDE_RANGING_FACTOR if wide_ranging?
          return AQUATIC_FACTOR if aquatic?
          return FLIGHTED_FACTOR if flighted?

          1.0
        end

        def space_requirement_sqm
          [@adult_weight.kilograms * SPACE_SQM_PER_KG * ranging_factor, MIN_SPACE_SQM].max
        end

        def group_living?
          @group_living
        end

        def solitary?
          !@group_living
        end

        def same_species?(other)
          other.is_a?(Species) && @scientific_name == other.scientific_name
        end

        def habitable?(temperature)
          @habitable_temperature_range.cover?(temperature)
        end

        def comfortable?(temperature)
          low = @habitable_temperature_range.begin.celsius
          high = @habitable_temperature_range.end.celsius
          margin = (high - low) * 0.15
          temperature.celsius.between?(low + margin, high - margin)
        end

        def climate_overlaps?(other)
          low = [@habitable_temperature_range.begin, other.habitable_temperature_range.begin].max
          high = [@habitable_temperature_range.end, other.habitable_temperature_range.end].min
          low <= high
        end

        def to_s
          "#{@name_ja}(#{@scientific_name})"
        end

        protected

        def components
          [@scientific_name]
        end
      end
    end
  end
end
