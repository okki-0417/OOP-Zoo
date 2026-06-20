# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '近親交配の回避' do
  sex      = Zoo::Domain::Animal::Sex
  breeding = Zoo::Domain::Breeding

  def births
    @births ||= []
  end

  def founder(name, sex)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 4000
    )
  end

  def offspring(name, sex, sire:, dam:)
    child = Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 365 * 4
    )
    births << Zoo::Domain::Birth.reconstitute(
      id: Zoo::Domain::Shared::Identifier.new, sire: sire, dam: dam,
      offspring: child, day: 0, season: Zoo::Domain::Season.spring
    )
    child
  end

  context '血縁のない成熟ペアのとき' do
    it '繁殖できること' do
      sire = founder('父系', sex.male)
      dam  = founder('母系', sex.female)
      expect { breeding.new(sire:, dam:, births:).conceive }.not_to raise_error
    end
  end

  context '親と子のとき' do
    it '近親なので繁殖できないこと' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      daughter = offspring('娘', sex.female, sire: father, dam: mother)
      expect do
        breeding.new(sire: father, dam: daughter, births:).conceive
      end.to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '近親交配であることが理由として示されること' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      daughter = offspring('娘', sex.female, sire: father, dam: mother)
      expect do
        breeding.new(sire: father, dam: daughter, births:).conceive
      end.to raise_error(Zoo::Domain::Errors::BreedingNotAllowed, /近親/)
    end
  end

  context '全きょうだい(両親が同じ)のとき' do
    it '繁殖できないこと' do
      father  = founder('父', sex.male)
      mother  = founder('母', sex.female)
      brother = offspring('兄', sex.male, sire: father, dam: mother)
      sister  = offspring('妹', sex.female, sire: father, dam: mother)
      expect do
        breeding.new(sire: brother, dam: sister, births:).conceive
      end.to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end
  end

  context '半きょうだい(片親だけ同じ)のとき' do
    it '繁殖できないこと' do
      father  = founder('父', sex.male)
      mother1 = founder('母1', sex.female)
      mother2 = founder('母2', sex.female)
      a = offspring('A', sex.male, sire: father, dam: mother1)
      b = offspring('B', sex.female, sire: father, dam: mother2)
      expect do
        breeding.new(sire: a, dam: b, births:).conceive
      end.to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end
  end
end
