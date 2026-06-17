# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      include Events::Recorder
      include Shared::Entity

      CRY_OUT_DAMAGE = 1

      HUNGER_PER_DAY = 10

      STARVATION_DAMAGE_PER_DAY = 2

      STRESS_DAMAGE_PER_DAY = 2

      MALNUTRITION_DAMAGE_PER_DAY = 2

      ILLNESS_VULNERABILITY_INCREMENT = 0.5

      attr_reader :id, :species, :name, :sex, :health, :hunger, :age_in_days, :death,
                  :parent_ids, :illness, :stress, :nutrition

      def initialize(species:, name:, sex:, max_health:, voice: :default,
                     age_in_days: 0, sire: nil, dam: nil, id: Shared::Identifier.new)
        @id = id
        @species = species
        @name = Name.new(name)
        @sex = sex
        @health = Health.full(max_health)
        @voice = Voice.from(voice == :default ? species.default_voice : voice)
        @age_in_days = AgeInDays.new(age_in_days)
        @hunger = Hunger.satisfied
        @stress = Stress.calm
        @nutrition = Nutrition.nourished
        @death = nil
        @illness = nil
        @immunities = []
        @parent_ids = [sire&.id, dam&.id].compact
      end

      def self.reconstitute(id:, species:, name:, sex:, health:, hunger:, age_in_days:, illness:, death:, parent_ids:,
                            stress: Stress.calm, immunities: [], nutrition: Nutrition.nourished)
        allocate.tap do |animal|
          animal.instance_variable_set(:@id, id)
          animal.instance_variable_set(:@species, species)
          animal.instance_variable_set(:@name, name)
          animal.instance_variable_set(:@sex, sex)
          animal.instance_variable_set(:@health, health)
          animal.instance_variable_set(:@hunger, hunger)
          animal.instance_variable_set(:@stress, stress)
          animal.instance_variable_set(:@nutrition, nutrition)
          animal.instance_variable_set(:@age_in_days, age_in_days)
          animal.instance_variable_set(:@voice, Voice.from(species.default_voice))
          animal.instance_variable_set(:@illness, illness)
          animal.instance_variable_set(:@immunities, immunities)
          animal.instance_variable_set(:@death, death)
          animal.instance_variable_set(:@parent_ids, parent_ids)
        end
      end

      def cry_out
        current_voice.tap { @health = @health.decreased_by(CRY_OUT_DAMAGE) if alive? }
      end

      def current_voice
        return '...' if incapacitated? || @voice.silent?

        @health.weak? ? "#{@voice}..." : @voice.to_s
      end

      def change_voice(new_voice)
        @voice = Voice.new(new_voice)
      end

      def heal(amount)
        raise ArgumentError, '回復量は0以上でなければなりません' if amount.negative?
        raise ArgumentError, '死んだ動物は回復できません' if dead?

        @health = @health.increased_by(amount)
        @health.current
      end

      def current_health
        @health.current
      end

      def alive?
        @death.nil?
      end

      def dead?
        !alive?
      end

      def incapacitated?
        dead? || @health.empty?
      end

      def die(cause: :unknown)
        return self if dead?

        @death = Death.new(cause: cause)
        record_event(Events::AnimalDied.new(animal: self, cause: cause))
        self
      end

      def parent_of?(other)
        other.is_a?(Animal) && other.parent_ids.include?(@id)
      end

      def sibling_of?(other)
        other.is_a?(Animal) && !!@parent_ids.intersect?(other.parent_ids)
      end

      def fall_ill(illness)
        raise Errors::DeadAnimal, "#{@name}は死亡しています" if dead?
        return self if immune_to?(illness)

        @illness = illness
        self
      end

      def vaccinate(illness)
        raise Errors::DeadAnimal, "#{@name}は死亡しています" if dead?
        raise Errors::VaccineUnavailable, "#{illness.name_ja}にはワクチンがありません" unless illness.contagious?

        @immunities << illness unless immune_to?(illness)
        self
      end

      def recover
        @immunities << @illness if @illness && !immune_to?(@illness)
        @illness = nil
        self
      end

      def sick?
        !@illness.nil?
      end

      def immune_to?(illness)
        @immunities.include?(illness)
      end

      def immunities
        @immunities.dup
      end

      def add_stress(amount)
        @stress = @stress.increased_by(amount)
        self
      end

      def relieve_stress(amount)
        @stress = @stress.decreased_by(amount)
        self
      end

      def stressed?
        @stress.stressed?
      end

      def injure(amount)
        raise ArgumentError, '外傷量は0以上でなければなりません' if amount.negative?
        return self if dead? || amount.zero?

        @health = @health.decreased_by(amount)
        die(cause: :injury) if @health.empty?
        self
      end

      def grow_older(days = 1)
        return self if dead?

        @age_in_days = @age_in_days.advanced_by(days)
        get_hungrier(@species.daily_hunger * days)
        @health = @health.decreased_by(STARVATION_DAMAGE_PER_DAY * days) if @hunger.starving?
        @health = @health.decreased_by(illness_damage(days)) if sick?
        @health = @health.decreased_by(STRESS_DAMAGE_PER_DAY * days) if @stress.severe?
        @health = @health.decreased_by(MALNUTRITION_DAMAGE_PER_DAY * days) if malnourished?

        if @age_in_days.past_lifespan?(@species)
          die(cause: :old_age)
        elsif @health.empty?
          die(cause: lethal_cause)
        end
        self
      end

      def get_hungrier(amount)
        @hunger = @hunger.increased_by(amount)
        self
      end

      def satisfy_hunger(amount)
        @hunger = @hunger.decreased_by(amount)
        self
      end

      def eat(food)
        raise Errors::DeadAnimal, "#{@name}は死亡しているため給餌できません" if dead?

        unless @species.diet_type.accepts?(food.category)
          raise Errors::IncompatibleFood,
                "#{@species.name_ja}(#{@species.diet_type.label})に#{food.name_ja}は与えられません"
        end

        satisfy_hunger(@species.satiety_from(food))
        self
      end

      def hungry?
        @hunger.hungry?
      end

      def starving?
        @hunger.starving?
      end

      NUTRITION_GAIN = 20
      NUTRITION_LOSS = 25

      def dine(foods)
        @nutrition = if @species.diet_satisfied_by?(foods)
                       @nutrition.improved_by(NUTRITION_GAIN)
                     else
                       @nutrition.declined_by(NUTRITION_LOSS)
                     end
        self
      end

      def malnourished?
        @nutrition.malnourished?
      end

      def well_nourished?
        !malnourished?
      end

      def life_stage
        @age_in_days.life_stage(@species)
      end

      def age_in_years
        @age_in_days.years
      end

      def mature?
        @age_in_days.mature?(@species)
      end

      def weaned?
        @age_in_days.weaned?(@species)
      end

      def fertile?
        alive? && mature? && !@age_in_days.past_breeding_age?(@species) &&
          !@health.weak? && !sick? && !stressed? && well_nourished?
      end

      def can_breed_with?(other)
        other.is_a?(Animal) &&
          @species.same_species?(other.species) &&
          @sex.opposite?(other.sex) &&
          fertile? && other.fertile?
      end

      def change_name(new_name)
        old_name = @name.to_s
        @name = Name.new(new_name)
        record_event(Events::AnimalRenamed.new(animal: self, old_name: old_name, new_name: @name.to_s))
        self
      end

      def to_s
        "#{@name}(#{@species.name_ja}/#{@sex.label}/#{life_stage.label})"
      end

      def illness_susceptibility
        stage = life_stage
        vulnerable = [stage.baby?, stage.elderly?, stressed?, malnourished?]
        1.0 + (vulnerable.count(true) * ILLNESS_VULNERABILITY_INCREMENT)
      end

      private

      def illness_damage(days)
        (@illness.daily_damage * illness_susceptibility * days).round
      end

      def lethal_cause
        return :illness if sick?
        return :starvation if starving?
        return :malnutrition if malnourished?

        :starvation
      end
    end
  end
end
