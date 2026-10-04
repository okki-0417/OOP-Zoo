# frozen_string_literal: true

class Animal < ApplicationRecord
  CRY_OUT_DAMAGE = 1
  STARVATION_DAMAGE_PER_DAY = 2
  STRESS_DAMAGE_PER_DAY = 2
  MALNUTRITION_DAMAGE_PER_DAY = 2
  ILLNESS_VULNERABILITY_INCREMENT = 0.5
  NUTRITION_GAIN = 20
  NUTRITION_LOSS = 25
  VISIBLE_STRESSED_PENALTY = 40
  VISIBLE_SICK_PENALTY = 40
  VISIBLE_WEAK_PENALTY = 20
  SEX_LABELS = { 'male' => 'オス', 'female' => 'メス' }.freeze

  validates :sex, inclusion: { in: SEX_LABELS.keys }

  def self.acquire(species_key:, name:, sex:, max_health:, age_in_days: 0, sire_id: nil, dam_id: nil)
    raise ArgumentError, "未知の種です: #{species_key}" unless SpeciesCatalog.find(species_key)

    health = Health.full(max_health)
    animal = new(
      species_key: species_key.to_s, sex: sex.to_s,
      health_current: health.current, health_max: health.max,
      hunger: Hunger.satisfied.level, stress: Stress.calm.level,
      nutrition: Nutrition.nourished.level, age_in_days: AgeInDays.new(age_in_days).value
    )
    animal.name = name
    animal.sire_id = sire_id
    animal.dam_id = dam_id
    animal.save!
    animal
  end

  def name=(value)
    super(Name.new(value).to_s)
  end

  def species
    @species ||= SpeciesCatalog.find(species_key)
  end

  def parent_ids
    [sire_id, dam_id].compact
  end

  # --- voice (species-derived; a custom voice is not persisted across reloads) ---

  def voice
    @voice_override || Voice.from(species.default_voice)
  end

  def change_voice(new_voice)
    @voice_override = Voice.new(new_voice)
    self
  end

  def cry_out
    current_voice.tap { write_health(health.decreased_by(CRY_OUT_DAMAGE)) if alive? }
  end

  def current_voice
    return '...' if incapacitated? || voice.silent?

    health.weak? ? "#{voice}..." : voice.to_s
  end

  # --- vitals ---

  def heal(amount)
    raise ArgumentError, '回復量は0以上でなければなりません' if amount.negative?
    raise ArgumentError, '死んだ動物は回復できません' if dead?

    write_health(health.increased_by(amount))
    health_current
  end

  def current_health
    health_current
  end

  def max_health
    health_max
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
    death_cause&.to_sym
  end

  def incapacitated?
    dead? || health.empty?
  end

  def die(cause: :unknown)
    return self if dead?

    self.death_cause = Death.new(cause: cause).cause.to_s
    self
  end

  def injure(amount)
    raise ArgumentError, '外傷量は0以上でなければなりません' if amount.negative?
    return self if dead? || amount.zero?

    write_health(health.decreased_by(amount))
    die(cause: :injury) if health.empty?
    self
  end

  # --- illness ---

  def illness
    IllnessCatalog.find(illness_key)
  end

  def fall_ill(illness)
    raise Errors::DeadAnimal, "#{name}は死亡しています" if dead?
    return self if immune_to?(illness)

    self.illness_key = IllnessCatalog.key_for(illness)
    self
  end

  def vaccinate(illness)
    raise Errors::DeadAnimal, "#{name}は死亡しています" if dead?
    raise Errors::VaccineUnavailable, "#{illness.name_ja}にはワクチンがありません" unless illness.contagious?

    write_attribute(:immunities, immunity_keys | [IllnessCatalog.key_for(illness)]) unless immune_to?(illness)
    self
  end

  def recover
    write_attribute(:immunities, immunity_keys | [illness_key.to_sym]) if illness && !immune_to?(illness)
    self.illness_key = nil
    self
  end

  def sick?
    !illness_key.nil?
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
    illnesses.find { |candidate| !immune_to?(candidate) }
  end

  def illness_name
    illness&.name_ja
  end

  def immune_to?(illness)
    immunity_keys.include?(IllnessCatalog.key_for(illness))
  end

  def immunities
    immunity_keys.map { |key| IllnessCatalog.find(key) }
  end

  # --- stress ---

  def add_stress(amount)
    write_stress(stress_vo.increased_by(amount))
    self
  end

  def relieve_stress(amount)
    write_stress(stress_vo.decreased_by(amount))
    self
  end

  def stressed?
    stress_vo.stressed?
  end

  def stress_level
    stress
  end

  # --- hunger / nutrition ---

  def grow_older(days = 1)
    return self if dead?

    write_age(age_vo.advanced_by(days))
    get_hungrier(species.daily_hunger * days)
    write_health(health.decreased_by(STARVATION_DAMAGE_PER_DAY * days)) if hunger_vo.starving?
    write_health(health.decreased_by(illness_damage(days))) if sick?
    write_health(health.decreased_by(STRESS_DAMAGE_PER_DAY * days)) if stress_vo.severe?
    write_health(health.decreased_by(MALNUTRITION_DAMAGE_PER_DAY * days)) if malnourished?

    if age_vo.past_lifespan?(species)
      die(cause: :old_age)
    elsif health.empty?
      die(cause: lethal_cause)
    end
    self
  end

  def get_hungrier(amount)
    write_hunger(hunger_vo.increased_by(amount))
    self
  end

  def satisfy_hunger(amount)
    write_hunger(hunger_vo.decreased_by(amount))
    self
  end

  def hungry?
    hunger_vo.hungry?
  end

  def starving?
    hunger_vo.starving?
  end

  def hunger_level
    hunger
  end

  def improve_nutrition
    write_nutrition(nutrition_vo.improved_by(NUTRITION_GAIN))
    self
  end

  def decline_nutrition
    write_nutrition(nutrition_vo.declined_by(NUTRITION_LOSS))
    self
  end

  def malnourished?
    nutrition_vo.malnourished?
  end

  def well_nourished?
    !malnourished?
  end

  def visible_condition
    score = 100
    score -= VISIBLE_STRESSED_PENALTY if stressed?
    score -= VISIBLE_SICK_PENALTY if sick?
    score -= VISIBLE_WEAK_PENALTY if health.weak?
    [score, 0].max
  end

  # --- aging / life stage ---

  def life_stage
    age_vo.life_stage(species)
  end

  def life_stage_label
    life_stage.label
  end

  def age_in_years
    age_vo.years
  end

  def mature?
    age_vo.mature?(species)
  end

  def weaned?
    age_vo.weaned?(species)
  end

  # --- species delegation ---

  def fertile?
    alive? && mature? && !age_vo.past_breeding_age?(species) &&
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

  # --- breeding ---

  def conceive(inbreeding: 0.0)
    raise Errors::BreedingNotAllowed, 'メスのみ妊娠できます' unless female?
    raise Errors::BreedingNotAllowed, '既に妊娠/抱卵中です' if expecting?

    write_pregnancy(Pregnancy.conceived(inbreeding: inbreeding))
    self.miscarried = false
    self
  end

  def expecting?
    !pregnancy_sex.nil?
  end

  def gestate(days = 1)
    return self unless expecting?

    if pregnancy_failing?
      miscarry
    else
      write_pregnancy(pregnancy_vo.advanced_by(days))
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
    expecting? && pregnancy_gestation_days >= species.gestation_period_days
  end

  def miscarried?
    miscarried
  end

  def expected_offspring_sex
    pregnancy_vo&.sex
  end

  def expected_offspring_inbreeding
    pregnancy_vo&.inbreeding_coefficient
  end

  def deliver
    raise Errors::BreedingNotAllowed, 'まだ出産/孵化の時期ではありません' unless ready_to_deliver?

    clear_pregnancy
    self
  end

  # --- naming / sex ---

  def name_animal(name:)
    self.name = name
    self
  end

  def change_name(new_name)
    self.name = new_name
    self
  end

  def male?
    sex == 'male'
  end

  def female?
    sex == 'female'
  end

  def sex_label
    SEX_LABELS.fetch(sex)
  end

  def sex_value
    sex.to_sym
  end

  def to_s
    "#{name}(#{species.name_ja}/#{sex_label}/#{life_stage.label})"
  end

  def as_json(*)
    current = Housing.current_for(self)
    {
      id: id, name: name, species: species_name,
      taxon_class: taxon_label, diet: diet_label,
      conservation_code: conservation_code, conservation_label: conservation_label,
      sex: sex_label, life_stage: life_stage_label, age_in_days: age_in_days,
      health: current_health, max_health: max_health, weak: weak?,
      hunger: hunger_level, starving: starving?, illness: illness_name,
      alive: alive?, cause: cause_of_death, parents: parent_ids,
      enclosure_id: current&.enclosure_id, enclosure_name: current&.enclosure&.name
    }
  end

  def summary_json
    {
      id: id, name: name, species: species_name, alive: alive?,
      health: current_health, max_health: max_health,
      ailing: alive? && (sick? || starving? || weak?)
    }
  end

  def illness_susceptibility
    stage = life_stage
    vulnerable = [stage.baby?, stage.elderly?, stressed?, malnourished?]
    1.0 + (vulnerable.count(true) * ILLNESS_VULNERABILITY_INCREMENT)
  end

  private

  def health
    Health.new(current: health_current, max: health_max)
  end

  def write_health(new_health)
    self.health_current = new_health.current
    self.health_max = new_health.max
  end

  def hunger_vo
    Hunger.new(hunger)
  end

  def write_hunger(new_hunger)
    self.hunger = new_hunger.level
  end

  def stress_vo
    Stress.new(stress)
  end

  def write_stress(new_stress)
    self.stress = new_stress.level
  end

  def nutrition_vo
    Nutrition.new(nutrition)
  end

  def write_nutrition(new_nutrition)
    self.nutrition = new_nutrition.level
  end

  def age_vo
    AgeInDays.new(age_in_days)
  end

  def write_age(new_age)
    self.age_in_days = new_age.value
  end

  def pregnancy_vo
    return nil unless expecting?

    Pregnancy.new(
      sex: Sex.new(pregnancy_sex.to_sym),
      gestation_days: pregnancy_gestation_days,
      inbreeding_coefficient: pregnancy_inbreeding_coefficient
    )
  end

  def write_pregnancy(pregnancy)
    self.pregnancy_sex = pregnancy.sex.value.to_s
    self.pregnancy_gestation_days = pregnancy.gestation_days
    self.pregnancy_inbreeding_coefficient = pregnancy.inbreeding_coefficient
  end

  def clear_pregnancy
    self.pregnancy_sex = nil
    self.pregnancy_gestation_days = nil
    self.pregnancy_inbreeding_coefficient = nil
  end

  def miscarry
    clear_pregnancy
    self.miscarried = true
  end

  def pregnancy_failing?
    starving? || stress_vo.severe? || malnourished?
  end

  def immunity_keys
    (read_attribute(:immunities) || []).map(&:to_sym)
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
