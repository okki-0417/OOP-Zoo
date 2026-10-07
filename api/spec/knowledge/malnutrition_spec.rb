# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '栄養失調' do
  macaque = SpeciesCatalog.japanese_macaque

  def troop
    enclosure = build(:enclosure, name: 'モンキーマウンテン', celsius: 20, capacity: 8)
    macaque = SpeciesCatalog.japanese_macaque
    subject_monkey = build(:animal, species: macaque, name: '主役')
    companion = build(:animal, :female, species: macaque, name: '仲間')
    [enclosure, subject_monkey, [subject_monkey, companion]]
  end

  def feed_daily(animal, foods)
    keeper = build(:keeper)
    Feeding.new(keeper: keeper, animal: animal, foods: foods).serve
    animal.settle_nutrition
  end

  def malnourish(animal, times: 4)
    times.times { feed_daily(animal, [FoodCatalog.banana]) }
    animal
  end

  describe '栄養バランスと福祉' do
    it '偏った餌しか与えられないと、満腹であってもストレスが増すこと' do
      enclosure, monkey, occupants = troop
      malnourish(monkey)
      expect(monkey).to be_malnourished
      expect(build(:welfare, animal: monkey, enclosure:, occupants:).daily_stress).to be > 0
    end

    it 'バランスの取れた給餌(果実と昆虫)は栄養を保ち、福祉を後押しすること' do
      enclosure, monkey, occupants = troop
      4.times { feed_daily(monkey, [FoodCatalog.banana, FoodCatalog.cricket]) }
      expect(monkey).not_to be_malnourished
      expect(build(:welfare, animal: monkey, enclosure:, occupants:).daily_stress).to be < 0
    end
  end

  describe '栄養失調と健康' do
    it '栄養失調が続くと体力を損なうこと' do
      monkey = build(:animal, species: macaque)
      malnourish(monkey)
      expect { monkey.grow_older(1) }.to change { monkey.current_health }.by(-Animal::MALNUTRITION_DAMAGE_PER_DAY)
    end

    it '深刻な栄養失調が続くと衰弱死し、死因が栄養失調として記録されること' do
      monkey = build(:animal, species: macaque, max_health: 4)
      malnourish(monkey)
      monkey.grow_older(2)
      expect(monkey).to be_dead
      expect(monkey.cause_of_death).to eq(:malnutrition)
    end
  end

  describe '栄養失調と繁殖' do
    it '栄養不良の個体は繁殖できないこと' do
      monkey = build(:animal, species: macaque)
      malnourish(monkey)
      expect(monkey).not_to be_fertile
    end

    it '妊娠中の母体の栄養失調は流産の要因になること' do
      dam = build(:animal, :female, species: macaque)
      dam.conceive
      malnourish(dam)
      dam.gestate(10)

      expect(dam).to be_miscarried
      expect(dam).not_to be_expecting
    end
  end
end
