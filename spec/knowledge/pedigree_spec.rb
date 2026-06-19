# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '血統と近親交配' do
  sex      = Zoo::Domain::Animal::Sex
  pedigree = Zoo::Domain::Pedigree
  catalog  = Zoo::Domain::SpeciesCatalog

  def founder(name, sex)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 4000
    )
  end

  def offspring(name, sex, sire:, dam:, age: 100)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: age, sire_id: sire&.id, dam_id: dam&.id
    )
  end

  def lookup_for(*animals)
    table = animals.to_h { |a| [a.id.to_s, a] }
    ->(id) { table[id.to_s] }
  end

  describe '近縁度(coancestry)' do
    it '血縁のない創始個体同士は0であること' do
      a = founder('A', sex.male)
      b = founder('B', sex.female)
      expect(pedigree.kinship(a, b, lookup_for(a, b))).to eq(0.0)
    end

    it '親と子は1/4であること' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      child = offspring('子', sex.male, sire: father, dam: mother)
      expect(pedigree.kinship(father, child, lookup_for(father, mother, child))).to eq(0.25)
    end

    it '全きょうだい(両親が同じ)は1/4であること' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      a = offspring('兄', sex.male, sire: father, dam: mother)
      b = offspring('妹', sex.female, sire: father, dam: mother)
      expect(pedigree.kinship(a, b, lookup_for(father, mother, a, b))).to eq(0.25)
    end

    it '半きょうだい(片親だけ同じ)は1/8であること' do
      father = founder('父', sex.male)
      mother1 = founder('母1', sex.female)
      mother2 = founder('母2', sex.female)
      a = offspring('A', sex.male, sire: father, dam: mother1)
      b = offspring('B', sex.female, sire: father, dam: mother2)
      expect(pedigree.kinship(a, b, lookup_for(father, mother1, mother2, a, b))).to eq(0.125)
    end
  end

  describe '近交係数(inbreeding coefficient)' do
    it '血縁のない親から生まれた子は0であること' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      child = offspring('子', sex.male, sire: father, dam: mother)
      expect(pedigree.inbreeding_coefficient(child, lookup_for(father, mother, child))).to eq(0.0)
    end

    it '全きょうだいの親から生まれた子は1/4であること' do
      gf = founder('祖父', sex.male)
      gm = founder('祖母', sex.female)
      brother = offspring('兄', sex.male, sire: gf, dam: gm)
      sister = offspring('姉', sex.female, sire: gf, dam: gm)
      child = offspring('近交子', sex.male, sire: brother, dam: sister, age: 50)
      lookup = lookup_for(gf, gm, brother, sister, child)
      expect(pedigree.inbreeding_coefficient(child, lookup)).to eq(0.25)
    end
  end

  describe '遺伝的多様性' do
    it '血縁のない個体ばかりの集団は平均近縁度が0であること' do
      animals = [founder('A', sex.male), founder('B', sex.female), founder('C', sex.male)]
      expect(pedigree.mean_kinship(animals, lookup_for(*animals))).to eq(0.0)
    end
  end

  describe '近交弱勢(inbreeding depression)' do
    it '近交係数が高い親から生まれた子ほど虚弱に(最大体力が低く)生まれること' do
      sire = build_adult(catalog.lion, name: '父', sex: sex.male)
      dam = build_adult(catalog.lion, name: '母', sex: sex.female)
      gestation = catalog.lion.gestation_period_days

      dam.conceive(sire_id: sire.id)
      dam.gestate(gestation)
      healthy = dam.deliver(name: '健全な子', sex: sex.male)

      dam.conceive(sire_id: sire.id)
      dam.gestate(gestation)
      inbred = dam.deliver(name: '近交の子', sex: sex.female, inbreeding: 0.25)

      expect(inbred.health.max).to be < healthy.health.max
    end
  end
end
