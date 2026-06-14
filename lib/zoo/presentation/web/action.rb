# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      # Web アクションの基底。params を受けて [ステータス, データ] を返す。
      # HTTP/JSON 整形と例外→ステータス翻訳はルーター(Web)側の責務。
      class Action
        def initialize(container:)
          @container = container
        end

        def call(_params)
          raise NotImplementedError, "#{self.class}#call を実装してください"
        end
      end
    end
  end
end
