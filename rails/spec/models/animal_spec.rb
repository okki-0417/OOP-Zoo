# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Animal do
  def build(name: 'Jack', sex: 'male', max_health: 100, age_in_days: 0, sire: nil, dam: nil)
    Animal.acquire(
      species_key: :lion, name: name, sex: sex,
      max_health: max_health, age_in_days: age_in_days, sire_id: sire&.id, dam_id: dam&.id
    )
  end

  describe '.acquire' do
    it '親を渡さなければ parent_ids は空であること' do
      expect(build.parent_ids).to eq([])
    end

    it '片親のみ渡すと nil は除かれ、その親だけが記録されること' do
      sire = build(name: '父')
      cub = build(name: '仔', sire: sire, dam: nil)
      expect(cub.parent_ids).to eq([sire.id])
    end

    it '未知の種を指定すると ArgumentError になること' do
      expect { Animal.acquire(species_key: :dragon, name: 'X', sex: 'male', max_health: 100) }
        .to raise_error(ArgumentError)
    end
  end

  describe '#threatened?' do
    it '種の保全状況が危急(VU)のライオンでは true を返すこと' do
      expect(build.threatened?).to be(true)
    end

    it '種の保全状況が低危険(LC)のニホンザルでは false を返すこと' do
      macaque = Animal.acquire(species_key: :japanese_macaque, name: 'Saru', sex: 'male', max_health: 100)
      expect(macaque.threatened?).to be(false)
    end
  end

  describe '#age_in_years' do
    it '日齢を365で割った端数切り捨ての歳を返すこと' do
      expect(build(age_in_days: (365 * 4) + 200).age_in_years).to eq(4)
    end
  end

  describe '#to_s' do
    it '名前(種/性別/ライフステージ)の形で表されること' do
      expect(build(name: 'Jack', age_in_days: 0).to_s).to eq('Jack(ライオン/オス/幼体)')
    end
  end

  describe '#visible_condition' do
    it '健康で落ち着いた個体は満点(100)であること' do
      expect(build.visible_condition).to eq(100)
    end

    it 'ストレス個体は VISIBLE_STRESSED_PENALTY(40)引かれること' do
      expect(build.tap { |a| a.add_stress(70) }.visible_condition).to eq(60)
    end

    it '病気の個体は VISIBLE_SICK_PENALTY(40)引かれること' do
      expect(build.tap { |a| a.fall_ill(IllnessCatalog.parasite) }.visible_condition).to eq(60)
    end

    it '衰弱した個体は VISIBLE_WEAK_PENALTY(20)引かれること' do
      expect(build.tap { |a| a.injure(85) }.visible_condition).to eq(80)
    end

    it '複数要因が重なっても0未満にはならないこと' do
      animal = build.tap do |a|
        a.add_stress(70)
        a.fall_ill(IllnessCatalog.parasite)
        a.injure(85)
      end
      expect(animal.visible_condition).to eq(0)
    end
  end

  describe '#susceptible?' do
    it '生きていて健康なら true を返すこと' do
      expect(build.susceptible?).to be(true)
    end

    it '発病済みなら false を返すこと' do
      expect(build.tap { |a| a.fall_ill(IllnessCatalog.cold) }.susceptible?).to be(false)
    end

    it '死亡していれば false を返すこと' do
      expect(build.tap(&:die).susceptible?).to be(false)
    end
  end

  describe '#contagious?' do
    it '感染性の病気(風邪)にかかっていれば true を返すこと' do
      expect(build.tap { |a| a.fall_ill(IllnessCatalog.cold) }.contagious?).to be(true)
    end

    it '非感染性の病気(骨折)では false を返すこと' do
      expect(build.tap { |a| a.fall_ill(IllnessCatalog.fracture) }.contagious?).to be(false)
    end

    it '健康なら false を返すこと' do
      expect(build.contagious?).to be(false)
    end

    it '感染性の病気を持っていても死亡していれば false を返すこと' do
      animal = build
      animal.fall_ill(IllnessCatalog.cold)
      animal.die
      expect(animal.contagious?).to be(false)
    end
  end

  describe '#contractible_illness' do
    it '免疫のない病気のうち最初のものを返すこと' do
      expect(build.contractible_illness([IllnessCatalog.cold, IllnessCatalog.pneumonia])).to eq(IllnessCatalog.cold)
    end

    it '免疫を持つ病気は飛ばし、罹りうる病気を返すこと' do
      animal = build.tap { |a| a.vaccinate(IllnessCatalog.cold) }
      illnesses = [IllnessCatalog.cold, IllnessCatalog.pneumonia]
      expect(animal.contractible_illness(illnesses)).to eq(IllnessCatalog.pneumonia)
    end

    it 'すべての病気に免疫があれば nil を返すこと' do
      animal = build.tap { |a| a.vaccinate(IllnessCatalog.cold) }
      expect(animal.contractible_illness([IllnessCatalog.cold])).to be_nil
    end
  end

  describe '永続化の往復' do
    it '体力・空腹・ストレス・病気・免疫を保存して再読み込みしても保たれること' do
      animal = build
      animal.injure(40)
      animal.get_hungrier(35)
      animal.add_stress(50)
      animal.fall_ill(IllnessCatalog.pneumonia)
      animal.vaccinate(IllnessCatalog.cold)
      animal.save!

      reloaded = Animal.find(animal.id)
      expect(reloaded.current_health).to eq(60)
      expect(reloaded.hunger_level).to eq(35)
      expect(reloaded.stress_level).to eq(50)
      expect(reloaded).to be_sick
      expect(reloaded.illness).to eq(IllnessCatalog.pneumonia)
      expect(reloaded.immune_to?(IllnessCatalog.cold)).to be(true)
    end

    it '死亡状態を保存して再読み込みしても保たれること' do
      animal = build.tap { |a| a.die(cause: :old_age) }
      animal.save!

      reloaded = Animal.find(animal.id)
      expect(reloaded).to be_dead
      expect(reloaded.cause_of_death).to eq(:old_age)
    end

    it '鳴き声は保存されず、再読み込み後は種の既定の声に戻ること(ライオンはガオー)' do
      animal = build
      animal.change_voice('モー')
      animal.save!

      reloaded = Animal.find(animal.id)
      expect(reloaded.cry_out).to eq('ガオー')
    end

    it '栄養状態・妊娠状態を保存して再読み込みしても保たれること' do
      dam = build(name: 'Mama', sex: 'female', age_in_days: 1200)
      dam.conceive
      dam.gestate(3)
      dam.decline_nutrition
      dam.decline_nutrition
      dam.decline_nutrition
      dam.save!

      reloaded = Animal.find(dam.id)
      expect(reloaded).not_to be_well_nourished
      expect(reloaded).to be_expecting
      expect(reloaded.expected_offspring_sex).not_to be_nil
    end
  end
end
