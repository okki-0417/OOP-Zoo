# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Meals
        include Shared::ValueObject

        attr_reader :categories

        def self.none
          new([])
        end

        def initialize(categories)
          unknown = categories.map(&:to_sym) - Food::CATEGORIES
          raise ArgumentError, "未知の餌カテゴリです: #{unknown.join(',')}" unless unknown.empty?

          @categories = categories.map(&:to_sym).uniq.sort.freeze
          freeze
        end

        def with(categories)
          self.class.new(@categories + categories)
        end

        def variety
          @categories.size
        end

        def balanced_for?(required_variety)
          variety >= required_variety
        end

        def to_s
          @categories.empty? ? '欠食' : @categories.join('・')
        end

        protected

        def components
          [@categories]
        end
      end
    end
  end
end
