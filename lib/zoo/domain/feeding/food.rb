# frozen_string_literal: true

module Zoo
  module Domain
    module Feeding
      # 餌を表す値オブジェクト。
      #
      # カテゴリ(肉・魚・昆虫・植物・果実・種子)は食性(DietType)と対応し、
      # 給餌時に動物の食性と整合するかを判断する。満腹度(satiety)は与えたときに
      # どれだけ空腹を満たすかを表す。
      class Food
        include Shared::ValueObject

        # DietType の受け入れカテゴリと対応する有効なカテゴリ。
        CATEGORIES = %i[meat fish insect plant fruit seed].freeze

        attr_reader :name_ja, :category, :satiety

        def initialize(name_ja:, category:, satiety:)
          symbol = category.to_sym
          raise ArgumentError, '餌の名称は必須です' if name_ja.to_s.empty?
          raise ArgumentError, "未知の餌カテゴリです: #{category}" unless CATEGORIES.include?(symbol)
          raise ArgumentError, '満腹度は1以上でなければなりません' unless satiety.is_a?(Integer) && satiety.positive?

          @name_ja = name_ja
          @category = symbol
          @satiety = satiety
          freeze
        end

        def to_s
          @name_ja
        end

        protected

        def components
          [@name_ja, @category, @satiety]
        end
      end
    end
  end
end
