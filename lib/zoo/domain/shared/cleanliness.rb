# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # 清潔度を表す不変の値オブジェクト。0(不衛生)〜100(清潔)。
      #
      # 飼育エリアは動物が暮らすほど汚れ(減少)、清掃で回復(増加)する。
      # 一定以下になると衛生悪化として動物の健康に影響しうる。
      class Cleanliness
        include ValueObject
        include Comparable

        MIN = 0
        MAX = 100
        FILTHY_THRESHOLD = 30

        attr_reader :level

        def self.spotless
          new(MAX)
        end

        def initialize(level)
          raise ArgumentError, '清潔度は整数でなければなりません' unless level.is_a?(Integer)

          @level = level.clamp(MIN, MAX)
          freeze
        end

        def soiled_by(amount)
          raise ArgumentError, '汚れ量は0以上でなければなりません' if amount.negative?

          self.class.new(@level - amount)
        end

        def cleaned_by(amount)
          raise ArgumentError, '清掃量は0以上でなければなりません' if amount.negative?

          self.class.new(@level + amount)
        end

        # 不衛生か(しきい値以下)。
        def filthy?
          @level <= FILTHY_THRESHOLD
        end

        def <=>(other)
          return nil unless other.is_a?(Cleanliness)

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
