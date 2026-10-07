# frozen_string_literal: true

module Zoo
  module Domain
    class Animal < ApplicationRecord
      CRY_OUT_DAMAGE = 1

      HUNGER_PER_DAY = 10

      STARVATION_DAMAGE_PER_DAY = 2

      STRESS_DAMAGE_PER_DAY = 2

      MALNUTRITION_DAMAGE_PER_DAY = 2

      ILLNESS_VULNERABILITY_INCREMENT = 0.5

      belongs_to :enclosure, optional: true, inverse_of: :animals
      belongs_to :sire, class_name: 'Zoo::Domain::Animal', optional: true
      belongs_to :dam, class_name: 'Zoo::Domain::Animal', optional: true

      attribute :species, Shared::ValueType.new(
        Species, load: SpeciesCatalog.method(:find), dump: ->(species) { SpeciesCatalog.key_of(species).to_s }
      )
      attribute :sex, Shared::ValueType.new(Sex, dump: ->(sex) { sex.value.to_s })
      attribute :hunger, Shared::ValueType.new(Hunger, dump: :level.to_proc), default: -> { Hunger.satisfied }
      attribute :stress, Shared::ValueType.new(Stress, dump: :level.to_proc), default: -> { Stress.calm }
      attribute :nutrition, Shared::ValueType.new(Nutrition, dump: :level.to_proc), default: -> { Nutrition.nourished }
      attribute :meals, Shared::ValueType.new(
        Meals, load: ->(value) { Meals.new(value.to_s.split(',')) }, dump: ->(meals) { meals.categories.join(',') }
      ), default: -> { Meals.none }
      attribute :illness, Shared::ValueType.new(
        Illness, load: IllnessCatalog.method(:find), dump: ->(illness) { IllnessCatalog.key_of(illness).to_s }
      )
      attribute :immunities, Shared::ListType.new(
        load: IllnessCatalog.method(:find), dump: ->(illness) { IllnessCatalog.key_of(illness).to_s }
      )

      scope :alive, -> { where(death_cause: nil) }
      scope :deceased, -> { where.not(death_cause: nil) }

      def name=(value)
        super(Name.new(value).to_s)
      end

      def voice=(value)
        @voice = value == :default ? nil : Voice.from(value)
      end

      def max_health=(value)
        super
        self.current_health = value if new_record?
      end

      def parents
        [sire, dam].compact
      end

      def move_to(enclosure)
        self.enclosure = enclosure
        self
      end

      def move_out
        self.enclosure = nil
        self
      end

      def cry_out
        current_voice.tap { self.health = health.decreased_by(CRY_OUT_DAMAGE) if alive? }
      end

      def current_voice
        return '...' if incapacitated? || voice.silent?

        health.weak? ? "#{voice}..." : voice.to_s
      end

      def change_voice(new_voice)
        @voice = Voice.new(new_voice)
      end

      def heal(amount)
        raise ArgumentError, '回復量は0以上でなければなりません' if amount.negative?
        raise ArgumentError, '死んだ動物は回復できません' if dead?

        self.health = health.increased_by(amount)
        health.current
      end

      def weak?
        health.weak?
      end

      def alive?
        death_cause.nil?
      end

      def dead?
        !alive?
      end

      def cause_of_death
        death&.cause
      end

      def cause_of_death_label
        death&.to_s
      end

      def incapacitated?
        dead? || health.empty?
      end

      def ailing?
        alive? && (sick? || starving? || weak?)
      end

      def die(cause: :unknown)
        return self if dead?

        self.death_cause = Death.new(cause: cause).cause
        self
      end

      def fall_ill(illness)
        raise Errors::DeadAnimal, "#{name}は死亡しています" if dead?
        return self if immune_to?(illness)

        self.illness = illness
        self
      end

      def vaccinate(illness)
        raise Errors::DeadAnimal, "#{name}は死亡しています" if dead?
        raise Errors::VaccineUnavailable, "#{illness.name_ja}にはワクチンがありません" unless illness.contagious?

        self.immunities = immunities + [illness] unless immune_to?(illness)
        self
      end

      def recover
        self.immunities = immunities + [illness] if illness && !immune_to?(illness)
        self.illness = nil
        self
      end

      def sick?
        !illness.nil?
      end

      def healthy?
        !sick?
      end

      def susceptible?
        alive? && healthy?
      end

      def contagious?
        alive? && (illness&.contagious? || false)
      end

      def contractible_illness(illnesses)
        illnesses.find { |illness| !immune_to?(illness) }
      end

      def illness_name
        illness&.name_ja
      end

      def immune_to?(illness)
        immunities.include?(illness)
      end

      def add_stress(amount)
        self.stress = stress.increased_by(amount)
        self
      end

      def relieve_stress(amount)
        self.stress = stress.decreased_by(amount)
        self
      end

      def stressed?
        stress.stressed?
      end

      def severely_stressed?
        stress.severe?
      end

      def stress_level
        stress.level
      end

      def injure(amount)
        raise ArgumentError, '外傷量は0以上でなければなりません' if amount.negative?
        return self if dead? || amount.zero?

        self.health = health.decreased_by(amount)
        die(cause: :injury) if health.empty?
        self
      end

      def grow_older(days = 1)
        return self if dead?

        self.age_in_days = age.advanced_by(days).value
        get_hungrier(species.daily_hunger * days)
        self.health = health.decreased_by(STARVATION_DAMAGE_PER_DAY * days) if hunger.starving?
        self.health = health.decreased_by(illness_damage(days)) if sick?
        self.health = health.decreased_by(STRESS_DAMAGE_PER_DAY * days) if stress.severe?
        self.health = health.decreased_by(MALNUTRITION_DAMAGE_PER_DAY * days) if malnourished?

        if age.past_lifespan?(species)
          die(cause: :old_age)
        elsif health.empty?
          die(cause: lethal_cause)
        end
        self
      end

      def get_hungrier(amount)
        self.hunger = hunger.increased_by(amount)
        self
      end

      def satisfy_hunger(amount)
        self.hunger = hunger.decreased_by(amount)
        self
      end

      def hungry?
        hunger.hungry?
      end

      def starving?
        hunger.starving?
      end

      def days_until_starving
        ((Hunger::MAX - hunger.level).to_f / species.daily_hunger).ceil
      end

      def hunger_level
        hunger.level
      end

      NUTRITION_GAIN = 20
      NUTRITION_LOSS = 25

      def take_meal(food_categories)
        self.meals = meals.with(food_categories)
        self
      end

      def fed_today?
        meals.variety.positive?
      end

      def settle_nutrition
        return self if dead?

        self.nutrition = if meals.balanced_for?(required_food_variety)
                           nutrition.improved_by(NUTRITION_GAIN)
                         else
                           nutrition.declined_by(NUTRITION_LOSS)
                         end
        self.meals = Meals.none
        self
      end

      def nutrition_level
        nutrition.level
      end

      def malnourished?
        nutrition.malnourished?
      end

      def well_nourished?
        !malnourished?
      end

      VISIBLE_STRESSED_PENALTY = 40
      VISIBLE_SICK_PENALTY = 40
      VISIBLE_WEAK_PENALTY = 20

      def visible_condition
        score = 100
        score -= VISIBLE_STRESSED_PENALTY if stressed?
        score -= VISIBLE_SICK_PENALTY if sick?
        score -= VISIBLE_WEAK_PENALTY if health.weak?
        [score, 0].max
      end

      def life_stage
        age.life_stage(species)
      end

      def life_stage_label
        life_stage.label
      end

      def age_in_years
        age.years
      end

      def mature?
        age.mature?(species)
      end

      def weaned?
        age.weaned?(species)
      end

      def fertile?
        alive? && mature? && !age.past_breeding_age?(species) &&
          !health.weak? && !sick? && !stressed? && well_nourished?
      end

      def breeds_year_round?
        species.breeds_year_round?
      end

      def breeding_season
        species.breeding_season
      end

      def threatened?
        species.threatened?
      end

      def species_name
        species.name_ja
      end

      def charisma
        species.charisma
      end

      def tradeable?
        species.tradeable?
      end

      def acquisition_price
        species.acquisition_price
      end

      def taxon_class
        species.taxon_class
      end

      def taxon_label
        species.taxon_label
      end

      def diet_label
        species.diet_label
      end

      def conservation_code
        species.conservation_code
      end

      def conservation_label
        species.conservation_label
      end

      def accepts?(food_category)
        species.accepts?(food_category)
      end

      def acceptable_food_categories
        Food::CATEGORIES.select { |category| accepts?(category) }
      end

      def metabolic_factor
        species.metabolic_factor
      end

      def required_food_variety
        species.required_food_variety
      end

      def habitable_temperature_range
        species.habitable_temperature_range
      end

      def space_requirement_sqm
        species.space_requirement_sqm
      end

      def group_living?
        species.group_living?
      end

      def contender?
        alive? && male? && mature? && group_living?
      end

      def conceive(inbreeding: 0.0)
        raise Errors::BreedingNotAllowed, 'メスのみ妊娠できます' unless sex.female?
        raise Errors::BreedingNotAllowed, '既に妊娠/抱卵中です' if expecting?

        self.pregnancy = Pregnancy.conceived(inbreeding: inbreeding)
        self.miscarried = false
        self
      end

      def expecting?
        !pregnancy.nil?
      end

      def gestate(days = 1)
        return self unless expecting?

        if pregnancy_failing?
          miscarry
        else
          self.pregnancy = pregnancy.advanced_by(days)
        end
        self
      end

      def gestation_period_days
        species.gestation_period_days
      end

      def litter_size
        species.litter_size
      end

      def ready_to_deliver?
        expecting? && pregnancy.gestation_days >= species.gestation_period_days
      end

      def expected_offspring_sex
        pregnancy&.sex
      end

      def expected_offspring_inbreeding
        pregnancy&.inbreeding_coefficient
      end

      def deliver
        raise Errors::BreedingNotAllowed, 'まだ出産/孵化の時期ではありません' unless ready_to_deliver?

        self.pregnancy = nil
        self
      end

      def name_animal(name:)
        self.name = name
        self
      end

      def change_name(new_name)
        self.name = new_name
        self
      end

      def male?
        sex.male?
      end

      def female?
        sex.female?
      end

      def sex_label
        sex.label
      end

      def sex_value
        sex.value
      end

      def to_s
        "#{name}(#{species.name_ja}/#{sex.label}/#{life_stage.label})"
      end

      def illness_susceptibility
        stage = life_stage
        vulnerable = [stage.baby?, stage.elderly?, stressed?, malnourished?]
        1.0 + (vulnerable.count(true) * ILLNESS_VULNERABILITY_INCREMENT)
      end

      private

      def health
        Health.new(current: current_health, max: max_health)
      end

      def health=(health)
        self.max_health = health.max
        self.current_health = health.current
      end

      def age
        AgeInDays.new(age_in_days)
      end

      def death
        death_cause && Death.new(cause: death_cause.to_sym)
      end

      def voice
        @voice ||= Voice.from(species.default_voice)
      end

      def pregnancy
        return nil if pregnancy_sex.nil?

        Pregnancy.new(
          sex: Sex.new(pregnancy_sex), gestation_days: gestation_days, inbreeding_coefficient: pregnancy_inbreeding
        )
      end

      def pregnancy=(pregnancy)
        self.pregnancy_sex = pregnancy && pregnancy.sex.value.to_s
        self.gestation_days = pregnancy&.gestation_days
        self.pregnancy_inbreeding = pregnancy&.inbreeding_coefficient
      end

      def pregnancy_failing?
        starving? || stress.severe? || malnourished?
      end

      def miscarry
        self.pregnancy = nil
        self.miscarried = true
      end

      def illness_damage(days)
        (illness.daily_damage * illness_susceptibility * days).round
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
