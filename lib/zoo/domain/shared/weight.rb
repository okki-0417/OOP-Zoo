# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # 体重を表す不変の値オブジェクト。内部はグラムで保持する。
      #
      # ゾウ(数トン)からハチドリ(数グラム)まで扱うため、最小単位を
      # グラムに統一し、kg/t での生成・表示を補助する。
      class Weight
        include ValueObject
        include Comparable

        attr_reader :grams

        def self.from_grams(grams)
          new(grams)
        end

        def self.from_kilograms(kilograms)
          new((kilograms * 1000).round)
        end

        def self.from_tons(tons)
          new((tons * 1_000_000).round)
        end

        def initialize(grams)
          raise ArgumentError, '体重は0より大きくなければなりません' unless grams.positive?

          @grams = grams.round
          freeze
        end

        def kilograms
          @grams / 1000.0
        end

        def tons
          @grams / 1_000_000.0
        end

        def +(other)
          self.class.new(@grams + other.grams)
        end

        def <=>(other)
          return nil unless other.is_a?(Weight)

          @grams <=> other.grams
        end

        def to_s
          if @grams >= 1_000_000
            format('%.2ft', tons)
          elsif @grams >= 1000
            format('%.1fkg', kilograms)
          else
            "#{@grams}g"
          end
        end

        protected

        def components
          [@grams]
        end
      end
    end
  end
end
