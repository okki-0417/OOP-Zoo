# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '近親交配の回避' do
  def founder(name, sex)
    Animal.new(
      species: SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 4000
    )
  end

  def offspring(name, sex, sire:, dam:)
    Animal.new(
      species: SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 365 * 4, sire: sire, dam: dam
    )
  end

  context '血縁のない成熟ペアのとき' do
    it '繁殖できること' do
      sire = founder('父系', Animal::Sex.male)
      dam  = founder('母系', Animal::Sex.female)
      expect { Breeding.new(sire:, dam:).conceive }.not_to raise_error
    end
  end

  context '親と子のとき' do
    it '近親なので繁殖できないこと' do
      father = founder('父', Animal::Sex.male)
      mother = founder('母', Animal::Sex.female)
      daughter = offspring('娘', Animal::Sex.female, sire: father, dam: mother)
      expect do
        Breeding.new(sire: father, dam: daughter).conceive
      end.to raise_error(Errors::BreedingNotAllowed)
    end

    it '近親交配であることが理由として示されること' do
      father = founder('父', Animal::Sex.male)
      mother = founder('母', Animal::Sex.female)
      daughter = offspring('娘', Animal::Sex.female, sire: father, dam: mother)
      expect do
        Breeding.new(sire: father, dam: daughter).conceive
      end.to raise_error(Errors::BreedingNotAllowed, /近親/)
    end
  end

  context '全きょうだい(両親が同じ)のとき' do
    it '繁殖できないこと' do
      father  = founder('父', Animal::Sex.male)
      mother  = founder('母', Animal::Sex.female)
      brother = offspring('兄', Animal::Sex.male, sire: father, dam: mother)
      sister  = offspring('妹', Animal::Sex.female, sire: father, dam: mother)
      expect do
        Breeding.new(sire: brother, dam: sister).conceive
      end.to raise_error(Errors::BreedingNotAllowed)
    end
  end

  context '半きょうだい(片親だけ同じ)のとき' do
    it '繁殖できないこと' do
      father  = founder('父', Animal::Sex.male)
      mother1 = founder('母1', Animal::Sex.female)
      mother2 = founder('母2', Animal::Sex.female)
      a = offspring('A', Animal::Sex.male, sire: father, dam: mother1)
      b = offspring('B', Animal::Sex.female, sire: father, dam: mother2)
      expect do
        Breeding.new(sire: a, dam: b).conceive
      end.to raise_error(Errors::BreedingNotAllowed)
    end
  end
end
