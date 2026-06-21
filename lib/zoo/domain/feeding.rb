# frozen_string_literal: true

module Zoo
  module Domain
    class Feeding
      SATIETY_FACTOR_RANGE = (0.3..3.0)

      def initialize(animal:, foods:, keeper: nil)
        @keeper = keeper
        @animal = animal
        @foods = foods
      end

      def serve
        reject!(attendance_violations + palatability_violations)
        @animal.satisfy_hunger(satiety)
        self
      end

      def nourish
        reject!(attendance_violations)
        if nutritionally_adequate?
          @animal.improve_nutrition
        else
          @animal.decline_nutrition
        end
        self
      end

      def satiety
        @foods.sum { |food| satiety_of(food) }
      end

      def nutritionally_adequate?
        offered_categories.size >= @animal.required_food_variety
      end

      private

      def reject!(violations)
        raise Errors::FeedingNotAllowed, violations.join(', ') unless violations.empty?
      end

      def attendance_violations
        violations = []
        unless @keeper.specialized_in?(@animal.taxon_class)
          violations << "飼育員#{@keeper.name}は#{@animal.taxon_class.label}を担当できません"
        end
        violations << "#{@animal.name}は死亡しているため給餌できません" if @animal.dead?
        violations
      end

      def palatability_violations
        @foods.reject { |food| @animal.accepts?(food.category) }
              .map { |food| "#{@animal.species_name}に#{food.name_ja}は与えられません" }
      end

      def satiety_of(food)
        factor = @animal.metabolic_factor.clamp(SATIETY_FACTOR_RANGE.begin, SATIETY_FACTOR_RANGE.end)
        [(food.satiety * factor).round, 1].max
      end

      def offered_categories
        @foods.select { |food| @animal.accepts?(food.category) }.map(&:category).uniq
      end
    end
  end
end
