# frozen_string_literal: true

class Feeding
  SATIETY_FACTOR_RANGE = (0.3..3.0)
  WORK_MINUTES = 10

  def initialize(animal:, foods:, keeper: nil)
    @keeper = keeper
    @animal = animal
    @foods = foods
  end

  def serve
    reject!(attendance_violations + palatability_violations)
    @keeper.clock_in(WORK_MINUTES)
    @animal.satisfy_hunger(satiety)
    @animal.take_meal(offered_categories)
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
    unless @keeper.available_for?(WORK_MINUTES)
      violations << "飼育員#{@keeper.name}は今日の勤務時間が足りません(残り#{@keeper.remaining_minutes}分)"
    end
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
