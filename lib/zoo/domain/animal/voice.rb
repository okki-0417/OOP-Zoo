# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # 鳴き声を表す値オブジェクト。
      #
      # nilは禁止だが、空文字は「無声」を表す正規の値として許可する
      # (キリン・蛇・カメなど鳴かない種を表現するため)。
      class Voice
        include Shared::ValueObject

        attr_reader :value

        # 鳴き声を持たない個体(無声)を生成するファクトリ。
        def self.silent
          new('')
        end

        # nilを許容する緩めの生成。種の既定の鳴き声(default_voice)が
        # nilの場合に無声へ正規化する用途。
        def self.from(value)
          value.nil? ? silent : new(value)
        end

        def initialize(value)
          raise ArgumentError, '鳴き声はnilにできません' if value.nil?

          @value = value.to_s
          freeze
        end

        # 鳴き声を持たない(空文字)か。
        def silent?
          @value.empty?
        end

        def to_s
          @value
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
