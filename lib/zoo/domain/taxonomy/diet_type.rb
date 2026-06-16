# frozen_string_literal: true

module Zoo
  module Domain
    module Taxonomy
      class DietType
        include Shared::ValueObject

        DIETS = {
          carnivore: { label: '肉食', categories: %i[meat] },
          piscivore: { label: '魚食', categories: %i[fish] },
          insectivore: { label: '昆虫食', categories: %i[insect] },
          herbivore: { label: '草食', categories: %i[plant fruit seed] },
          frugivore: { label: '果実食', categories: %i[fruit seed] },
          omnivore: { label: '雑食', categories: %i[meat fish insect plant fruit seed] }
        }.freeze

        attr_reader :value

        DIETS.each_key do |key|
          define_singleton_method(key) { new(key) }
        end

        def initialize(value)
          symbol = value.to_sym
          raise ArgumentError, "未知の食性です: #{value}" unless DIETS.key?(symbol)

          @value = symbol
          freeze
        end

        def accepts?(food_category)
          acceptable_categories.include?(food_category.to_sym)
        end

        def acceptable_categories
          DIETS.fetch(@value)[:categories]
        end

        def predatory?
          acceptable_categories.include?(:meat) || acceptable_categories.include?(:fish)
        end

        def label
          DIETS.fetch(@value)[:label]
        end

        def to_s
          label
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
