# frozen_string_literal: true

module Zoo
  module Domain
    class Food
      include Shared::ValueObject

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
