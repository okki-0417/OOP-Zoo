# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Pedigree do
  def pedigree(animal_id: 'x', parent_ids: [], age: 0)
    described_class.new(animal_id, parent_ids, age)
  end

  describe '等価性' do
    it '同じ animal_id と parent_ids を持つ Pedigree は等しいこと' do
      id = Zoo::Domain::Shared::Identifier.new
      expect(pedigree(animal_id: id, parent_ids: [])).to eq(pedigree(animal_id: id, parent_ids: []))
    end

    it '異なる animal_id を持つ Pedigree は等しくないこと' do
      expect(pedigree(animal_id: 'a')).not_to eq(pedigree(animal_id: 'b'))
    end
  end

  describe '#kinship_with' do
    it 'other が nil のとき 0.0 であること' do
      expect(pedigree.kinship_with(nil, ->(_id) {})).to eq(0.0)
    end

    it '親を持たない創始個体同士は 0.0 であること' do
      a = pedigree(animal_id: 'a', age: 100)
      b = pedigree(animal_id: 'b', age: 100)
      expect(a.kinship_with(b, ->(_id) {})).to eq(0.0)
    end

    it '自分自身との近縁度は 0.5 であること' do
      a = pedigree(animal_id: 'x', parent_ids: [], age: 100)
      expect(a.kinship_with(a, ->(_id) {})).to eq(0.5)
    end
  end

  describe '#inbreeding_coefficient' do
    it '親を辿れない個体は 0.0 であること' do
      expect(pedigree.inbreeding_coefficient(->(_id) {})).to eq(0.0)
    end
  end
end
