# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '妊娠と出産' do
  catalog = Zoo::Domain::SpeciesCatalog
  sex     = Zoo::Domain::Animal::Sex
  errors = Zoo::Domain::Errors

  def pair_of(species)
    sire, dam = build_pair(species)
    Zoo::Domain::BreedingPair.new(sire: sire, dam: dam)
  end

  describe '妊娠の始まり' do
    it '交尾すると妊娠/抱卵が始まること' do
      pair = pair_of(catalog.lion)
      pair.mate
      expect(pair).to be_expecting
    end

    it '妊娠中はさらに交尾できないこと' do
      pair = pair_of(catalog.lion)
      pair.mate
      expect { pair.mate }.to raise_error(errors::BreedingNotAllowed)
    end
  end

  describe '妊娠期間' do
    it '体の大きな種ほど妊娠期間が長いこと(ライオン110日 < ゾウ660日)' do
      expect(catalog.african_elephant.gestation_period_days).to be > catalog.lion.gestation_period_days
    end

    it '妊娠期間に満たないうちは出産できないこと' do
      pair = pair_of(catalog.lion)
      pair.mate
      pair.advance(109)
      expect(pair).not_to be_ready_to_deliver
    end

    it '妊娠期間が満ちると出産できること' do
      pair = pair_of(catalog.lion)
      pair.mate
      pair.advance(110)
      expect(pair).to be_ready_to_deliver
    end
  end

  describe '出産' do
    it '生まれた子は0日齢の幼体で、両親が血統に記録されること' do
      pair = pair_of(catalog.lion)
      pair.mate
      pair.advance(catalog.lion.gestation_period_days)
      cub = pair.deliver(name: '仔', sex: sex.male)

      expect(cub.age_in_days.value).to eq(0)
      expect(cub.life_stage).to be_baby
      expect(cub.parent_ids).to contain_exactly(pair.sire.id, pair.dam.id)
    end

    it '出産すると妊娠が解け、再び交尾できること' do
      pair = pair_of(catalog.lion)
      pair.mate
      pair.advance(catalog.lion.gestation_period_days)
      pair.deliver(name: '仔', sex: sex.female)

      expect(pair).not_to be_expecting
      expect { pair.mate }.not_to raise_error
    end
  end

  describe '流産' do
    context '妊娠中の母体が飢餓に陥ると' do
      it '流産し、妊娠が解けて出産できないこと' do
        pair = pair_of(catalog.lion)
        pair.mate
        pair.dam.get_hungrier(100)
        pair.advance(50)

        expect(pair).to be_miscarried
        expect(pair).not_to be_expecting
        expect { pair.deliver(name: '仔', sex: sex.male) }.to raise_error(errors::BreedingNotAllowed)
      end
    end

    context '妊娠中の母体が過度のストレスを抱えると' do
      it '流産すること' do
        pair = pair_of(catalog.lion)
        pair.mate
        pair.dam.add_stress(90)
        pair.advance(50)

        expect(pair).to be_miscarried
        expect(pair).not_to be_expecting
      end
    end
  end
end
