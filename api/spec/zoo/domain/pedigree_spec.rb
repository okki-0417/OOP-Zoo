# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Pedigree do
      def founder(name, sex)
        Animal.new(species: SpeciesCatalog.lion, name: name, sex: sex, max_health: 100, age_in_days: 3000)
      end

      def offspring(name, sex, sire:, dam:, age: 100)
        Animal.new(
          species: SpeciesCatalog.lion, name: name, sex: sex, max_health: 100, age_in_days: age, sire:, dam:
        )
      end

      describe '#coancestry' do
        it 'いずれかが nil なら 0.0 を返すこと' do
          a = founder('A', Animal::Sex.male)
          expect(described_class.new.coancestry(a, nil)).to eq(0.0)
          expect(described_class.new.coancestry(nil, a)).to eq(0.0)
        end

        it '親の分からない個体同士は 0.0 を返すこと' do
          a = founder('A', Animal::Sex.male)
          b = founder('B', Animal::Sex.female)
          expect(described_class.new.coancestry(a, b)).to eq(0.0)
        end

        it '自分自身との近縁度は 0.5(近交が無ければ)であること' do
          a = founder('A', Animal::Sex.male)
          expect(described_class.new.coancestry(a, a)).to eq(0.5)
        end

        it '引数の順序によらず同じ値を返すこと' do
          father = founder('父', Animal::Sex.male)
          mother = founder('母', Animal::Sex.female)
          child = offspring('子', Animal::Sex.male, sire: father, dam: mother)
          pedigree = described_class.new
          expect(pedigree.coancestry(father, child)).to eq(pedigree.coancestry(child, father))
        end
      end

      describe '#inbreeding_of' do
        it '親が1頭しか分からない個体は 0.0 であること' do
          mother = founder('母', Animal::Sex.female)
          child = offspring('子', Animal::Sex.male, sire: nil, dam: mother)
          expect(described_class.new.inbreeding_of(child)).to eq(0.0)
        end

        it '全きょうだいを両親に持つ子の近交係数は 1/4 であること' do
          gf = founder('祖父', Animal::Sex.male)
          gm = founder('祖母', Animal::Sex.female)
          brother = offspring('兄', Animal::Sex.male, sire: gf, dam: gm)
          sister  = offspring('姉', Animal::Sex.female, sire: gf, dam: gm)
          child   = offspring('子', Animal::Sex.male, sire: brother, dam: sister)
          expect(described_class.new.inbreeding_of(child)).to eq(0.25)
        end
      end

      describe '#related?' do
        it '親の分からない創始個体同士は偽であること' do
          a = founder('A', Animal::Sex.male)
          b = founder('B', Animal::Sex.female)
          expect(described_class.new.related?(a, b)).to be(false)
        end

        it '親子は真であること' do
          father = founder('父', Animal::Sex.male)
          mother = founder('母', Animal::Sex.female)
          daughter = offspring('娘', Animal::Sex.female, sire: father, dam: mother)
          expect(described_class.new.related?(father, daughter)).to be(true)
        end

        it 'きょうだいは真であること' do
          father = founder('父', Animal::Sex.male)
          mother = founder('母', Animal::Sex.female)
          brother = offspring('兄', Animal::Sex.male, sire: father, dam: mother)
          sister  = offspring('妹', Animal::Sex.female, sire: father, dam: mother)
          expect(described_class.new.related?(brother, sister)).to be(true)
        end
      end

      describe '#mean_kinship' do
        it '個体が1頭以下なら 0.0 であること' do
          a = founder('A', Animal::Sex.male)
          expect(described_class.new.mean_kinship([a])).to eq(0.0)
          expect(described_class.new.mean_kinship([])).to eq(0.0)
        end
      end
    end
  end
end
