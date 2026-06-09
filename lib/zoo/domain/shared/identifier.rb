# frozen_string_literal: true

require 'securerandom'

module Zoo
  module Domain
    module Shared
      # エンティティの同一性を表す識別子。
      #
      # エンティティは属性が変化しても「同じ個体」であり続ける。その同一性を
      # 値そのもの(整数や文字列)ではなく専用の値オブジェクトで表すことで、
      # 異なる種類のIDの取り違えを型レベルで防ぐ。
      class Identifier
        include ValueObject

        attr_reader :value

        # 引数を省略するとUUIDを自動採番する。
        def initialize(value = SecureRandom.uuid)
          raise ArgumentError, '識別子は空にできません' if value.to_s.empty?

          @value = value.to_s
          freeze
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
