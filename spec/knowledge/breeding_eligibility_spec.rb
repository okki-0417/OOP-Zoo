# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '繁殖できる相手' do
  sex      = Zoo::Domain::Animal::Sex
  breeding = Zoo::Domain::Breeding
  catalog  = Zoo::Domain::SpeciesCatalog
  errors   = Zoo::Domain::Errors

  def adult(species, sex, name: '個体')
    Zoo::Domain::Animal.new(species: species, name: name, sex: sex, max_health: 100, age_in_days: 4000)
  end

  context '同種の異性で双方が成熟しているとき' do
    it '繁殖できること' do
      sire = adult(catalog.lion, sex.male, name: '父')
      dam  = adult(catalog.lion, sex.female, name: '母')
      expect { breeding.new(sire:, dam:).conceive }.not_to raise_error
    end
  end

  context '相手が同性のとき' do
    it '異性でなければ繁殖できないこと' do
      sire = adult(catalog.lion, sex.male, name: 'オス1')
      dam  = adult(catalog.lion, sex.male, name: 'オス2')
      expect { breeding.new(sire:, dam:).conceive }
        .to raise_error(errors::BreedingNotAllowed, /異性/)
    end
  end

  context '相手が別の種のとき' do
    it '同種でなければ繁殖できないこと' do
      sire = adult(catalog.lion, sex.male, name: 'ライオン')
      dam  = adult(catalog.grevys_zebra, sex.female, name: 'シマウマ')
      expect { breeding.new(sire:, dam:).conceive }
        .to raise_error(errors::BreedingNotAllowed, /同種/)
    end
  end

  context '相手がまだ成熟していないとき' do
    it '成熟していなければ繁殖できないこと' do
      sire = adult(catalog.lion, sex.male, name: '父')
      cub  = Zoo::Domain::Animal.new(
        species: catalog.lion, name: '仔', sex: sex.female, max_health: 100, age_in_days: 0
      )
      expect { breeding.new(sire:, dam: cub).conceive }
        .to raise_error(errors::BreedingNotAllowed, /成熟/)
    end
  end
end
