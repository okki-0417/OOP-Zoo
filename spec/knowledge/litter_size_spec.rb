# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '産仔数' do
  catalog = Zoo::Domain::SpeciesCatalog

  def delivered_litter(species, inbreeding: 0.0)
    sire, dam = build_pair(species)
    dam.conceive(sire_id: sire.id, inbreeding: inbreeding)
    dam.gestate(species.gestation_period_days)
    dam.deliver_litter(name: '仔')
  end

  describe '種ごとの産仔数' do
    context '大型で少産少死(K戦略)の種' do
      it 'アフリカゾウは一度に1頭だけ産むこと' do
        expect(catalog.african_elephant.litter_size).to eq(1)
      end

      it 'ライオンは一度に2〜4頭の幼体を産むこと' do
        expect(catalog.lion.litter_size).to be_between(2, 4)
      end
    end

    context '多産多死(r戦略)の種' do
      it 'ニシキゴイ(魚類)は一度に数百を産卵すること' do
        expect(catalog.koi.litter_size).to be >= 100
      end

      it 'アカハライモリ(両生類)は一度に多数を産卵すること' do
        expect(catalog.japanese_fire_belly_newt.litter_size).to be >= 50
      end
    end

    it '産仔数は種の生活史と整合すること(大型少産のゾウ < 多産のコイ)' do
      expect(catalog.african_elephant.litter_size).to be < catalog.koi.litter_size
    end
  end

  describe '出産の帰結' do
    it '出産すると産仔数ぶんの幼体が一度に生まれること' do
      expect(delivered_litter(catalog.lion).size).to eq(catalog.lion.litter_size)
    end

    it '生まれた各個体は0日齢の幼体であること' do
      delivered_litter(catalog.lion).each do |cub|
        expect(cub.age_in_days).to eq(0)
        expect(cub.life_stage).to be_baby
      end
    end

    it '同腹の全個体に同じ両親が血統として記録されること' do
      sire, dam = build_pair(catalog.lion)
      dam.conceive(sire_id: sire.id)
      dam.gestate(catalog.lion.gestation_period_days)
      litter = dam.deliver_litter(name: '仔')

      litter.each { |cub| expect(cub.parent_ids).to contain_exactly(sire.id, dam.id) }
    end

    it '近交係数は同腹の全個体に等しく適用されること' do
      litter = delivered_litter(catalog.lion, inbreeding: 0.25)
      maxes = litter.map(&:max_health).uniq
      expect(maxes.size).to eq(1)
      expect(maxes.first).to be < Zoo::Domain::Animal::NEWBORN_HEALTH
    end
  end

  describe '個体群への影響' do
    it '多産の種ほど一度の繁殖で個体数を大きく増やせること' do
      expect(catalog.koi.litter_size).to be > catalog.lion.litter_size
    end

    it '少産の種は1頭の死亡が個体群に与える打撃が大きいこと(ゾウは1産1頭)' do
      expect(catalog.african_elephant.litter_size).to eq(1)
    end
  end
end
