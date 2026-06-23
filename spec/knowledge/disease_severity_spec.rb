# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '疾病の重症度と伝播' do
  catalog   = Zoo::Domain::SpeciesCatalog
  illnesses = Zoo::Domain::IllnessCatalog
  contagion = Zoo::Domain::Contagion

  def sick_lion(age_in_days:, stress: 0, illness: Zoo::Domain::IllnessCatalog.cold)
    lion = Zoo::Domain::SpeciesCatalog.lion
    animal = Zoo::Domain::Animal.new(
      species: lion, name: 'X', sex: Zoo::Domain::Animal::Sex.male, max_health: 100, age_in_days: age_in_days
    )
    animal.add_stress(stress) if stress.positive?
    animal.fall_ill(illness)
    animal
  end

  def pen
    Zoo::Domain::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 6
    )
  end

  def occupancy(enclosure, occupants)
    Zoo::Domain::Occupancy.new(enclosure, occupants)
  end

  describe '重症度(進行の速さ)' do
    it '重い病気(肺炎)は軽い病気(風邪)より速く体力を奪うこと' do
      cold_one = sick_lion(age_in_days: 365 * 5, illness: illnesses.cold)
      pneumonia_one = sick_lion(age_in_days: 365 * 5, illness: illnesses.pneumonia)
      cold_one.grow_older(3)
      pneumonia_one.grow_older(3)

      expect(pneumonia_one.current_health).to be < cold_one.current_health
    end
  end

  describe '脆弱な個体' do
    it '幼体は成体より重症化(体力減)しやすいこと' do
      baby = sick_lion(age_in_days: 0)
      adult = sick_lion(age_in_days: 365 * 5)
      baby.grow_older(3)
      adult.grow_older(3)

      expect(baby.current_health).to be < adult.current_health
    end

    it '老齢個体は成体より重症化しやすいこと' do
      old = sick_lion(age_in_days: 365 * 13)
      adult = sick_lion(age_in_days: 365 * 5)
      old.grow_older(3)
      adult.grow_older(3)

      expect(old.current_health).to be < adult.current_health
    end

    it '高ストレス(免疫低下)の個体は成体より重症化しやすいこと' do
      stressed = sick_lion(age_in_days: 365 * 5, stress: 70)
      calm = sick_lion(age_in_days: 365 * 5)
      stressed.grow_older(3)
      calm.grow_older(3)

      expect(stressed.current_health).to be < calm.current_health
    end
  end

  describe '伝播は確率的' do
    it '感染源と同居しても、必ず感染するとは限らないこと(伝播判定に失敗する乱数)' do
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)
      healthy = build_adult(catalog.lion, name: '健康')

      contagion.new(occupancy(pen, [carrier, healthy]), random: instance_double(Random, rand: 99)).spread

      expect(healthy).not_to be_sick
    end

    it '伝播判定に成功する乱数では感染が起きること' do
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)
      healthy = build_adult(catalog.lion, name: '健康')

      contagion.new(occupancy(pen, [carrier, healthy]), random: instance_double(Random, rand: 0)).spread

      expect(healthy).to be_sick
    end

    it '同じ伝播条件(rand=60)でも、清潔なら防げる伝播が不衛生なエリアでは起きること' do
      infect_into = lambda do |enclosure|
        carrier = build_adult(catalog.lion, name: '感染源')
        carrier.fall_ill(illnesses.cold)
        healthy = build_adult(catalog.lion, name: '健康')
        contagion.new(occupancy(enclosure, [carrier, healthy]), random: instance_double(Random, rand: 60)).spread
        healthy
      end

      expect(infect_into.call(pen)).not_to be_sick
      expect(infect_into.call(pen.tap { |p| p.soil(90) })).to be_sick
    end

    it '免疫を持つ個体は伝播の対象から外れること' do
      immune = build_adult(catalog.lion, name: '接種済み')
      immune.vaccinate(illnesses.cold)
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)

      contagion.new(occupancy(pen, [immune, carrier]), random: instance_double(Random, rand: 0)).spread

      expect(immune).not_to be_sick
    end
  end
end
