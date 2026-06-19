# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Pedigree do
  sex = Zoo::Domain::Animal::Sex

  def lion(name, sex:, age:, sire: nil, dam: nil)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, max_health: 100, age_in_days: age, sire_id: sire&.id, dam_id: dam&.id
    )
  end

  def lookup_for(*animals)
    table = animals.to_h { |a| [a.id.to_s, a] }
    ->(id) { table[id.to_s] }
  end

  describe '.kinship' do
    it '同一個体(創始)の自分自身との近縁度は1/2であること' do
      a = lion('A', sex: sex.male, age: 4000)
      expect(described_class.kinship(a, a, lookup_for(a))).to eq(0.5)
    end

    it 'lookup が辿れない祖先は無縁(0)として扱うこと' do
      father = lion('父', sex: sex.male, age: 4000)
      mother = lion('母', sex: sex.female, age: 4000)
      child = lion('子', sex: sex.male, age: 100, sire: father, dam: mother)
      stranger = lion('他人', sex: sex.female, age: 100)

      expect(described_class.kinship(child, stranger, lookup_for(child, stranger))).to eq(0.0)
    end
  end

  describe '.inbreeding_coefficient' do
    it '親を辿れない個体(創始)は0であること' do
      a = lion('A', sex: sex.male, age: 4000)
      expect(described_class.inbreeding_coefficient(a, lookup_for(a))).to eq(0.0)
    end
  end

  describe '.mean_kinship' do
    it '個体が1頭以下なら0であること' do
      a = lion('A', sex: sex.male, age: 4000)
      expect(described_class.mean_kinship([a], lookup_for(a))).to eq(0.0)
      expect(described_class.mean_kinship([], lookup_for)).to eq(0.0)
    end
  end
end
