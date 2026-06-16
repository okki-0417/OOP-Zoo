# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '近親交配の回避' do
  sex = Zoo::Domain::Animal::Sex
  policy = Zoo::Domain::Breeding::BreedingPolicy

  def founder(name, sex)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 4000
    )
  end

  def offspring(name, sex, sire:, dam:)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: 365 * 4, sire: sire, dam: dam
    )
  end

  context '血縁のない成熟ペアのとき' do
    it '繁殖できること' do
      expect(policy.can_mate?(founder('父系', sex.male), founder('母系', sex.female))).to be(true)
    end
  end

  context '親と子のとき' do
    it '近親なので繁殖できないこと' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      daughter = offspring('娘', sex.female, sire: father, dam: mother)
      expect(policy.can_mate?(father, daughter)).to be(false)
    end

    it '近親交配であることが理由として示されること' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      daughter = offspring('娘', sex.female, sire: father, dam: mother)
      expect(policy.rejection_reason(father, daughter)).to include('近親')
    end
  end

  context '全きょうだい(両親が同じ)のとき' do
    it '繁殖できないこと' do
      father = founder('父', sex.male)
      mother = founder('母', sex.female)
      brother = offspring('兄', sex.male, sire: father, dam: mother)
      sister = offspring('妹', sex.female, sire: father, dam: mother)
      expect(policy.can_mate?(brother, sister)).to be(false)
    end
  end

  context '半きょうだい(片親だけ同じ)のとき' do
    it '繁殖できないこと' do
      father = founder('父', sex.male)
      mother1 = founder('母1', sex.female)
      mother2 = founder('母2', sex.female)
      a = offspring('A', sex.male, sire: father, dam: mother1)
      b = offspring('B', sex.female, sire: father, dam: mother2)
      expect(policy.can_mate?(a, b)).to be(false)
    end
  end
end
