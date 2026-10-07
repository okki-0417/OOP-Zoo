# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '血統と近親交配' do
  def pedigree
    Pedigree.new
  end

  def founder(name, sex)
    Animal.new(
      species: SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 4000
    )
  end

  def offspring(name, sex, sire:, dam:, age: 100)
    Animal.new(
      species: SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: age, sire: sire, dam: dam
    )
  end

  describe '近縁度(coancestry)' do
    it '血縁のない創始個体同士は0であること' do
      a = founder('A', Animal::Sex.male)
      b = founder('B', Animal::Sex.female)
      expect(pedigree.coancestry(a, b)).to eq(0.0)
    end

    it '親と子は1/4であること' do
      father = founder('父', Animal::Sex.male)
      mother = founder('母', Animal::Sex.female)
      child = offspring('子', Animal::Sex.male, sire: father, dam: mother)
      expect(pedigree.coancestry(father, child)).to eq(0.25)
    end

    it '全きょうだい(両親が同じ)は1/4であること' do
      father = founder('父', Animal::Sex.male)
      mother = founder('母', Animal::Sex.female)
      a = offspring('兄', Animal::Sex.male, sire: father, dam: mother)
      b = offspring('妹', Animal::Sex.female, sire: father, dam: mother)
      expect(pedigree.coancestry(a, b)).to eq(0.25)
    end

    it '半きょうだい(片親だけ同じ)は1/8であること' do
      father  = founder('父', Animal::Sex.male)
      mother1 = founder('母1', Animal::Sex.female)
      mother2 = founder('母2', Animal::Sex.female)
      a = offspring('A', Animal::Sex.male, sire: father, dam: mother1)
      b = offspring('B', Animal::Sex.female, sire: father, dam: mother2)
      expect(pedigree.coancestry(a, b)).to eq(0.125)
    end
  end

  describe '近交係数(inbreeding coefficient)' do
    it '血縁のない親から生まれた子は0であること' do
      father = founder('父', Animal::Sex.male)
      mother = founder('母', Animal::Sex.female)
      expect(pedigree.coancestry(father, mother)).to eq(0.0)
    end

    it '全きょうだいの親から生まれた子は1/4であること' do
      gf      = founder('祖父', Animal::Sex.male)
      gm      = founder('祖母', Animal::Sex.female)
      brother = offspring('兄', Animal::Sex.male, sire: gf, dam: gm)
      sister  = offspring('姉', Animal::Sex.female, sire: gf, dam: gm)
      expect(pedigree.coancestry(brother, sister)).to eq(0.25)
    end
  end

  describe '遺伝的多様性' do
    it '血縁のない個体ばかりの集団は平均近縁度が0であること' do
      animals = [founder('A', Animal::Sex.male), founder('B', Animal::Sex.female), founder('C', Animal::Sex.male)]
      expect(pedigree.mean_kinship(animals)).to eq(0.0)
    end
  end

  describe '近交弱勢(inbreeding depression)' do
    it '近交係数が高い親から生まれた子ほど虚弱に(最大体力が低く)生まれること' do
      sire     = build_adult(SpeciesCatalog.lion, name: '父', sex: Animal::Sex.male)
      dam      = build_adult(SpeciesCatalog.lion, name: '母', sex: Animal::Sex.female)
      gestation = SpeciesCatalog.lion.gestation_period_days

      dam.conceive
      dam.gestate(gestation)
      healthy = Birth.new(sire: sire, dam: dam, name: '健全な子').deliver.offspring

      dam.conceive(inbreeding: 0.25)
      dam.gestate(gestation)
      inbred = Birth.new(sire: sire, dam: dam, name: '近交の子').deliver.offspring

      expect(inbred.max_health).to be < healthy.max_health
    end
  end
end
