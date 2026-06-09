# frozen_string_literal: true

module Zoo
  module Domain
    module Taxonomy
      # 生物種を表す値オブジェクト。動物個体(Animal)が参照する不変の分類情報。
      #
      # 学名で同一性が決まる。和名・綱・食性・保全状況に加え、飼育・繁殖・
      # エリア相性の判断に必要な生態情報(適温域・寿命・性成熟年齢・妊娠期間・
      # 成獣体重・群れ性・既定の鳴き声)を保持する。
      class Species
        include Shared::ValueObject

        attr_reader :name_ja, :scientific_name, :taxon_class, :diet_type,
                    :conservation_status, :habitable_temperature_range,
                    :lifespan_years, :maturity_age_years, :gestation_period_days,
                    :adult_weight, :default_voice

        def initialize(name_ja:, scientific_name:, taxon_class:, diet_type:,
                       conservation_status:, habitable_temperature_range:,
                       lifespan_years:, maturity_age_years:, gestation_period_days:,
                       adult_weight:, default_voice: nil, group_living: false)
          raise ArgumentError, '和名は必須です' if name_ja.to_s.empty?
          raise ArgumentError, '学名は必須です' if scientific_name.to_s.empty?

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
          freeze
        end

        # 他種を捕食しうる食性か。
        def predatory?
          @diet_type.predatory?
        end

        # 群れで暮らす種か。
        def group_living?
          @group_living
        end

        # 単独性(縄張りを持ち群れない)か。同種を同居させると争う。
        def solitary?
          !@group_living
        end

        def same_species?(other)
          other.is_a?(Species) && @scientific_name == other.scientific_name
        end

        # 指定気温がこの種の適温域に収まるか。
        def habitable?(temperature)
          @habitable_temperature_range.cover?(temperature)
        end

        # 2種の適温域が重なるか(同一エリアで飼える気候か)。
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
