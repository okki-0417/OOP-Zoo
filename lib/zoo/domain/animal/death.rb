# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # 個体の死亡を表す不変の値オブジェクト。
      #
      # 生きている個体は death が nil、死亡した個体は Death の値を持つ。
      # これにより「死因は死亡時にしか意味を持たない」という不変条件を
      # 型レベルで表現する。将来は死亡時刻・場所・加害個体などを保持しうる。
      class Death
        include Shared::ValueObject

        attr_reader :cause

        def initialize(cause: :unknown)
          @cause = cause
          freeze
        end

        def to_s
          cause.to_s
        end

        protected

        def components
          [@cause]
        end
      end
    end
  end
end
