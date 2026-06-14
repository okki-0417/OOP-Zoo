# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 環境エンリッチメント(刺激)の度合いを表す不変の値オブジェクト。0(殺風景)〜100(豊か)。
      #
      # 採食装置・遊具・隠れ場所などがもたらす刺激の量。動物が暮らすほど新奇性は薄れ(減少)、
      # 飼育員が新たな刺激を補充して回復(増加)する。一定以下になると退屈し常同行動を招く。
      class Enrichment
        include Shared::ValueObject
        include Comparable

        MIN = 0
        MAX = 100
        BARREN_THRESHOLD = 30

        attr_reader :level

        def self.stimulating
          new(MAX)
        end

        def initialize(level)
          raise ArgumentError, '刺激度は整数でなければなりません' unless level.is_a?(Integer)

          @level = level.clamp(MIN, MAX)
          freeze
        end

        def depleted_by(amount)
          raise ArgumentError, '減衰量は0以上でなければなりません' if amount.negative?

          self.class.new(@level - amount)
        end

        def enriched_by(amount)
          raise ArgumentError, '補充量は0以上でなければなりません' if amount.negative?

          self.class.new(@level + amount)
        end

        # 殺風景か(しきい値以下)。退屈・常同行動の要因になる。
        def barren?
          @level <= BARREN_THRESHOLD
        end

        def <=>(other)
          return nil unless other.is_a?(Enrichment)

          @level <=> other.level
        end

        def to_s
          "#{@level}/#{MAX}"
        end

        protected

        def components
          [@level]
        end
      end
    end
  end
end
