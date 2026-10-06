# frozen_string_literal: true

module Zoo
  module Domain
    class Ration
      MAX_SERVINGS = 6

      def initialize(animal:, foods:)
        @animal = animal
        @catalog = foods
      end

      def foods
        @foods ||= topped_up(balanced_base)
      end

      private

      def balanced_base
        @catalog.select { |food| @animal.accepts?(food.category) }
                .group_by(&:category)
                .map { |_category, candidates| candidates.max_by(&:satiety) }
                .sort_by { |food| -food.satiety }
                .first(@animal.required_food_variety)
      end

      def topped_up(base)
        return base if base.empty?

        servings = base.dup
        servings << base.first while satiety_of(servings) < @animal.hunger_level && servings.size < MAX_SERVINGS
        servings
      end

      def satiety_of(servings)
        Feeding.new(animal: @animal, foods: servings).satiety
      end
    end
  end
end
