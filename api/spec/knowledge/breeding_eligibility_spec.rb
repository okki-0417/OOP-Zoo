# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '繁殖できる相手' do
  def adult(species, sex, name: '個体')
    Animal.new(species: species, name: name, sex: sex, max_health: 100, age_in_days: 4000)
  end

  context '同種の異性で双方が成熟しているとき' do
    it '繁殖できること' do
      sire = adult(SpeciesCatalog.lion, Animal::Sex.male, name: '父')
      dam  = adult(SpeciesCatalog.lion, Animal::Sex.female, name: '母')
      expect { Breeding.new(sire:, dam:).conceive }.not_to raise_error
    end
  end

  context '相手が同性のとき' do
    it 'オス同士では母(メス)役が不在となり繁殖できないこと' do
      sire = adult(SpeciesCatalog.lion, Animal::Sex.male, name: 'オス1')
      dam  = adult(SpeciesCatalog.lion, Animal::Sex.male, name: 'オス2')
      expect { Breeding.new(sire:, dam:).conceive }
        .to raise_error(Errors::BreedingNotAllowed, /メス/)
    end

    it 'メス同士では父(オス)役が不在となり繁殖できないこと' do
      sire = adult(SpeciesCatalog.lion, Animal::Sex.female, name: 'メス1')
      dam  = adult(SpeciesCatalog.lion, Animal::Sex.female, name: 'メス2')
      expect { Breeding.new(sire:, dam:).conceive }
        .to raise_error(Errors::BreedingNotAllowed, /オス/)
    end
  end

  context '相手が別の種のとき' do
    it '同種でなければ繁殖できないこと' do
      sire = adult(SpeciesCatalog.lion, Animal::Sex.male, name: 'ライオン')
      dam  = adult(SpeciesCatalog.grevys_zebra, Animal::Sex.female, name: 'シマウマ')
      expect { Breeding.new(sire:, dam:).conceive }
        .to raise_error(Errors::BreedingNotAllowed, /同種/)
    end
  end

  context '相手がまだ成熟していないとき' do
    it '成熟していなければ繁殖できないこと' do
      sire = adult(SpeciesCatalog.lion, Animal::Sex.male, name: '父')
      cub  = Animal.new(
        species: SpeciesCatalog.lion, name: '仔', sex: Animal::Sex.female, max_health: 100, age_in_days: 0
      )
      expect { Breeding.new(sire:, dam: cub).conceive }
        .to raise_error(Errors::BreedingNotAllowed, /成熟/)
    end
  end
end
