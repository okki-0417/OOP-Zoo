# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '個体群管理(交配推奨)' do
  sex         = Zoo::Domain::Animal::Sex
  recommender = Zoo::Domain::MatingRecommendation

  def founder(name, sex, age: 3000)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: age
    )
  end

  def offspring(name, sex, sire:, dam:, age: 1500)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: age, sire: sire, dam: dam
    )
  end

  def lookup_for(*animals)
    table = animals.to_h { |a| [a.id.to_s, a] }
    ->(id) { table[id.to_s] }
  end

  describe '遺伝的多様性を保つ推奨' do
    context '血縁の異なる候補が複数いるとき' do
      it '近縁度が最も低くなるペアを推奨すること' do
        male    = founder('M', sex.male, age: 3600)
        granny  = founder('祖母', sex.female, age: 3600)
        mother  = offspring('娘', sex.female, sire: male, dam: granny, age: 2500)
        outside = founder('外', sex.male, age: 3600)
        f2      = offspring('孫娘', sex.female, sire: outside, dam: mother, age: 1500)
        f1      = founder('F1', sex.female, age: 3000)

        candidates = [male, f1, f2]
        lookup = lookup_for(male, granny, mother, outside, f2, f1)

        expect(recommender.recommend(candidates, lookup)).to eq([male, f1])
      end
    end

    context '組める相手が近親(親子)しかいないとき' do
      it '近親は推奨せず、推奨ペアが無いこと' do
        male     = founder('父', sex.male, age: 3600)
        mother   = founder('母', sex.female, age: 3600)
        daughter = offspring('娘', sex.female, sire: male, dam: mother, age: 1500)

        candidates = [male, daughter]
        lookup = lookup_for(male, mother, daughter)

        expect(recommender.recommend(candidates, lookup)).to be_nil
      end
    end

    context '繁殖可能な異性がいないとき' do
      it '推奨ペアが無いこと' do
        m1 = founder('M1', sex.male)
        m2 = founder('M2', sex.male)

        expect(recommender.recommend([m1, m2], lookup_for(m1, m2))).to be_nil
      end
    end
  end
end
