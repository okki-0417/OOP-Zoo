# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '妊娠と出産' do
  def mated_dam(species)
    sire, dam = build_pair(species)
    dam.conceive
    [sire, dam]
  end

  describe '妊娠の始まり' do
    it '交尾するとメス(母体)に妊娠/抱卵が宿ること' do
      _sire, dam = mated_dam(SpeciesCatalog.lion)
      expect(dam).to be_expecting
    end

    it '妊娠は母体自身の状態であり、オスは身ごもらないこと' do
      sire, dam = build_pair(SpeciesCatalog.lion)
      dam.conceive
      expect(sire).not_to be_expecting
    end

    it '妊娠中はさらに交尾できないこと' do
      _sire, dam = mated_dam(SpeciesCatalog.lion)
      expect { dam.conceive }.to raise_error(Errors::BreedingNotAllowed)
    end
  end

  describe '妊娠期間' do
    it '体の大きな種ほど妊娠期間が長いこと(ライオン110日 < ゾウ660日)' do
      expect(SpeciesCatalog.african_elephant.gestation_period_days).to be > SpeciesCatalog.lion.gestation_period_days
    end

    it '妊娠期間に満たないうちは出産できないこと' do
      _sire, dam = mated_dam(SpeciesCatalog.lion)
      dam.gestate(109)
      expect(dam).not_to be_ready_to_deliver
    end

    it '妊娠期間が満ちると出産できること' do
      _sire, dam = mated_dam(SpeciesCatalog.lion)
      dam.gestate(110)
      expect(dam).to be_ready_to_deliver
    end
  end

  describe '出産' do
    it '生まれた子は0日齢の幼体で、両親が血統に記録されること' do
      sire, dam = mated_dam(SpeciesCatalog.lion)
      dam.gestate(SpeciesCatalog.lion.gestation_period_days)
      cub = Birth.new(sire: sire, dam: dam, name: '仔').deliver.offspring

      expect(cub.age_in_days).to eq(0)
      expect(cub.life_stage).to be_baby
      expect(cub.parents).to contain_exactly(sire, dam)
    end

    it '出産すると妊娠が解け、再び交尾できること' do
      sire, dam = mated_dam(SpeciesCatalog.lion)
      dam.gestate(SpeciesCatalog.lion.gestation_period_days)
      Birth.new(sire: sire, dam: dam, name: '仔').deliver

      expect(dam).not_to be_expecting
      expect { dam.conceive }.not_to raise_error
    end
  end

  describe '流産' do
    context '妊娠中の母体が飢餓に陥ると' do
      it '流産し、妊娠が解けて出産できないこと' do
        sire, dam = mated_dam(SpeciesCatalog.lion)
        dam.get_hungrier(100)
        dam.gestate(50)

        expect(dam).to be_miscarried
        expect(dam).not_to be_expecting
        expect { Birth.new(sire: sire, dam: dam, name: '仔').deliver }.to raise_error(Errors::BreedingNotAllowed)
      end
    end

    context '妊娠中の母体が過度のストレスを抱えると' do
      it '流産すること' do
        _sire, dam = mated_dam(SpeciesCatalog.lion)
        dam.add_stress(90)
        dam.gestate(50)

        expect(dam).to be_miscarried
        expect(dam).not_to be_expecting
      end
    end
  end

  describe '日々の経過' do
    context '妊娠中のメスがエリアで1日を過ごすと' do
      it '妊娠日数が1日進むこと' do
        enclosure = Enclosure.new(
          name: '猛獣舎', temperature: Temperature.celsius(20), capacity: 4
        )
        sire, dam = mated_dam(SpeciesCatalog.lion)
        occupancy = build_occupancy(enclosure, [sire, dam])
        AnimalDay.new(animal: dam, enclosure:, occupancy:).run
        dam.gestate(SpeciesCatalog.lion.gestation_period_days - 2)
        expect(dam).not_to be_ready_to_deliver
        dam.gestate(1)
        expect(dam).to be_ready_to_deliver
      end
    end
  end
end
