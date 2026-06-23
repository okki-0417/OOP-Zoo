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

      attr_reader :id, :species, :parent_ids, :illness

      def name
        @name.to_s
      end

      def age_in_days
        @age_in_days.value
      end

      def initialize(species:, name:, sex:, max_health:, voice: :default,
                     age_in_days: 0, sire_id: nil, dam_id: nil, id: Shared::Identifier.new)
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
        @pregnancy = nil
        @miscarried = false
        @parent_ids = [sire_id, dam_id].compact
      end

      def self.reconstitute(id:, species:, name:, sex:, health:, hunger:, age_in_days:, illness:, death:, parent_ids:,
                            stress: Stress.calm, immunities: [], nutrition: Nutrition.nourished,
                            pregnancy: nil, miscarried: false)
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
          animal.instance_variable_set(:@pregnancy, pregnancy)
          animal.instance_variable_set(:@miscarried, miscarried)
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

      def max_health
        @health.max
      end

      def weak?
        @health.weak?
      end

      def alive?
        @death.nil?
      end

      def dead?
        !alive?
      end

      def cause_of_death
        @death&.cause
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

      def healthy?
        !sick?
      end

      def susceptible?
        alive? && healthy?
      end

      def contagious?
        alive? && (@illness&.contagious? || false)
      end

      def contractible_illness(illnesses)
        illnesses.find { |illness| !immune_to?(illness) }
      end

      def illness_name
        @illness&.name_ja
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

      def stress_level
        @stress.level
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

      def hungry?
        @hunger.hungry?
      end

      def starving?
        @hunger.starving?
      end

      def hunger_level
        @hunger.level
      end

      NUTRITION_GAIN = 20
      NUTRITION_LOSS = 25

      def improve_nutrition
        @nutrition = @nutrition.improved_by(NUTRITION_GAIN)
        self
      end

      def decline_nutrition
        @nutrition = @nutrition.declined_by(NUTRITION_LOSS)
        self
      end

      def malnourished?
        @nutrition.malnourished?
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
        score -= VISIBLE_WEAK_PENALTY if @health.weak?
        [score, 0].max
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

      def breeds_year_round?
        @species.breeds_year_round?
      end

      def breeding_season
        @species.breeding_season
      end

      def threatened?
        @species.conservation_status.threatened?
      end

      def species_name
        @species.name_ja
      end

      def taxon_class
        @species.taxon_class
      end

      def accepts?(food_category)
        @species.accepts?(food_category)
      end

      def metabolic_factor
        @species.metabolic_factor
      end

      def required_food_variety
        @species.required_food_variety
      end

      def habitable_temperature_range
        @species.habitable_temperature_range
      end

      def space_requirement_sqm
        @species.space_requirement_sqm
      end

      def group_living?
        @species.group_living?
      end

      def contender?
        alive? && male? && mature? && group_living?
      end

      def conceive(inbreeding: 0.0)
        raise Errors::BreedingNotAllowed, 'メスのみ妊娠できます' unless @sex.female?
        raise Errors::BreedingNotAllowed, '既に妊娠/抱卵中です' if expecting?

        @pregnancy = Pregnancy.conceived(inbreeding: inbreeding)
        @miscarried = false
        self
      end

      def expecting?
        !@pregnancy.nil?
      end

      def gestate(days = 1)
        return self unless expecting?

        if pregnancy_failing?
          miscarry
        else
          @pregnancy = @pregnancy.advanced_by(days)
        end
        self
      end

      def gestation_period_days
        @species.gestation_period_days
      end

      def litter_size
        @species.litter_size
      end

      def ready_to_deliver?
        expecting? && @pregnancy.gestation_days >= @species.gestation_period_days
      end

      def miscarried?
        @miscarried
      end

      def expected_offspring_sex
        @pregnancy&.sex
      end

      def expected_offspring_inbreeding
        @pregnancy&.inbreeding_coefficient
      end

      def deliver
        raise Errors::BreedingNotAllowed, 'まだ出産/孵化の時期ではありません' unless ready_to_deliver?

        @pregnancy = nil
        self
      end

      def name_animal(name:, keeper_id: nil, occurred_on: 0)
        @name = Name.new(name)
        record_event(Events::AnimalNamed.new(animal: self, name: name, keeper_id: keeper_id, occurred_on: occurred_on))
        self
      end

      def change_name(new_name)
        old_name = @name.to_s
        @name = Name.new(new_name)
        record_event(Events::AnimalRenamed.new(animal: self, old_name: old_name, new_name: @name.to_s))
        self
      end

      def male?
        @sex.male?
      end

      def female?
        @sex.female?
      end

      def sex_label
        @sex.label
      end

      def sex_value
        @sex.value
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

      def pregnancy_failing?
        starving? || @stress.severe? || malnourished?
      end

      def miscarry
        @pregnancy = nil
        @miscarried = true
      end

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
