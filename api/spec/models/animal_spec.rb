# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal do
  describe '#initialize' do
    it '親を渡さなければ parents は空であること' do
      expect(build(:animal).parents).to eq([])
    end

    it '片親のみ渡すと nil は除かれ、その親だけが parents に記録されること' do
      sire = build(:animal, name: '父')
      cub = build(:animal, name: '仔', sire: sire, dam: nil)
      expect(cub.parents).to eq([sire])
    end
  end

  describe '#move_to / #move_out' do
    let(:hill) { build(:enclosure, name: '丘') }
    let(:lion) { build(:animal, name: 'レオ') }

    it 'move_to(丘) で enclosure が丘になり、move_out で nil に戻ること' do
      lion.move_to(hill)
      expect(lion.enclosure).to eq(hill)

      lion.move_out
      expect(lion.enclosure).to be_nil
    end

    it 'どのエリアにもいないレオを move_out すると「レオはどのエリアにも収容されていません」の ArgumentError になること' do
      expect { lion.move_out }.to raise_error(ArgumentError, 'レオはどのエリアにも収容されていません')
    end
  end

  describe '#threatened?' do
    it '種の保全状況が危急(VU)のライオンでは true を返すこと' do
      expect(build(:animal).threatened?).to be(true)
    end

    it '種の保全状況が低危険(LC)のニホンザルでは false を返すこと' do
      macaque = build(:animal, :newborn, species: SpeciesCatalog.japanese_macaque, name: 'Saru')
      expect(macaque.threatened?).to be(false)
    end
  end

  describe '#age_in_years' do
    it '日齢を365で割った端数切り捨ての歳を返すこと' do
      expect(build(:animal, age_in_days: (365 * 4) + 200).age_in_years).to eq(4)
    end
  end

  describe '#to_s' do
    it '名前(種/性別/ライフステージ)の形で表されること' do
      expect(build(:animal, name: 'Jack', age_in_days: 0).to_s).to eq('Jack(ライオン/オス/幼体)')
    end
  end

  describe '#visible_condition' do
    it '健康で落ち着いた個体は満点(100)であること' do
      expect(build(:animal).visible_condition).to eq(100)
    end

    it 'ストレス個体は VISIBLE_STRESSED_PENALTY(40)引かれること' do
      expect(build(:animal).tap { |a| a.add_stress(70) }.visible_condition).to eq(60)
    end

    it '病気の個体は VISIBLE_SICK_PENALTY(40)引かれること' do
      expect(build(:animal).tap { |a| a.fall_ill(IllnessCatalog.parasite) }.visible_condition).to eq(60)
    end

    it '衰弱した個体は VISIBLE_WEAK_PENALTY(20)引かれること' do
      expect(build(:animal).tap { |a| a.injure(85) }.visible_condition).to eq(80)
    end

    it '複数要因が重なっても0未満にはならないこと' do
      animal = build(:animal).tap do |a|
        a.add_stress(70)
        a.fall_ill(IllnessCatalog.parasite)
        a.injure(85)
      end
      expect(animal.visible_condition).to eq(0)
    end
  end

  describe '#susceptible?' do
    it '生きていて健康なら true を返すこと' do
      expect(build(:animal).susceptible?).to be(true)
    end

    it '発病済みなら false を返すこと' do
      expect(build(:animal).tap { |a| a.fall_ill(IllnessCatalog.cold) }.susceptible?).to be(false)
    end

    it '死亡していれば false を返すこと' do
      expect(build(:animal).tap(&:die).susceptible?).to be(false)
    end
  end

  describe '#contagious?' do
    it '感染性の病気(風邪)にかかっていれば true を返すこと' do
      expect(build(:animal).tap { |a| a.fall_ill(IllnessCatalog.cold) }.contagious?).to be(true)
    end

    it '非感染性の病気(骨折)では false を返すこと' do
      expect(build(:animal).tap { |a| a.fall_ill(IllnessCatalog.fracture) }.contagious?).to be(false)
    end

    it '健康なら false を返すこと' do
      expect(build(:animal).contagious?).to be(false)
    end

    it '感染性の病気を持っていても死亡していれば false を返すこと' do
      animal = build(:animal)
      animal.fall_ill(IllnessCatalog.cold)
      animal.die
      expect(animal.contagious?).to be(false)
    end
  end

  describe '#contractible_illness' do
    it '免疫のない病気のうち最初のものを返すこと' do
      expect(build(:animal).contractible_illness([IllnessCatalog.cold, IllnessCatalog.pneumonia])).to eq(IllnessCatalog.cold)
    end

    it '免疫を持つ病気は飛ばし、罹りうる病気を返すこと' do
      animal = build(:animal).tap { |a| a.vaccinate(IllnessCatalog.cold) }
      expect(animal.contractible_illness([IllnessCatalog.cold, IllnessCatalog.pneumonia])).to eq(IllnessCatalog.pneumonia)
    end

    it 'すべての病気に免疫があれば nil を返すこと' do
      animal = build(:animal).tap { |a| a.vaccinate(IllnessCatalog.cold) }
      expect(animal.contractible_illness([IllnessCatalog.cold])).to be_nil
    end
  end

  describe '#dup' do
    it '複製の免疫を増やしても元の個体の免疫は増えないこと' do
      animal = build(:animal)
      copy = animal.dup
      copy.fall_ill(IllnessCatalog.cold)
      copy.recover
      expect(animal.immunities).to eq([])
      expect(copy.immunities).to eq([IllnessCatalog.cold])
    end

    it '保存済みの個体を複製すると id を持たない新規の個体になり、元の個体とは等価でないこと' do
      animal = create(:animal)
      copy = animal.dup
      expect(copy).to be_new_record
      expect(copy).not_to eq(animal)
    end
  end

  describe '#days_until_starving' do
    it 'ライオン(1日+10)の空腹度95は1日、空腹度0は10日を返すこと' do
      expect(build(:animal).get_hungrier(95).days_until_starving).to eq(1)
      expect(build(:animal).days_until_starving).to eq(10)
    end
  end

  describe '#cause_of_death_label / #acceptable_food_categories' do
    it '老衰で死んだライオンは "老衰"、生きていれば nil を返すこと' do
      expect(build(:animal).die(cause: :old_age).cause_of_death_label).to eq('老衰')
      expect(build(:animal).cause_of_death_label).to be_nil
    end

    it 'ライオン(肉食)が食べられる餌の分類は [:meat] であること' do
      expect(build(:animal).acceptable_food_categories).to eq([:meat])
    end
  end

  describe '#take_meal' do
    it '[:meat] を2回 take_meal しても meals.categories は [:meat] のままであること' do
      animal = build(:animal)
      animal.take_meal([:meat]).take_meal([:meat])
      expect(animal.meals.categories).to eq([:meat])
    end
  end

  describe '#ailing?' do
    it '健康なら false、肺炎(sick?)・空腹度100(starving?)・体力15/100(weak?)のいずれかなら true を返すこと' do
      expect(build(:animal).ailing?).to be(false)
      expect(build(:animal).tap { |a| a.fall_ill(IllnessCatalog.pneumonia) }.ailing?).to be(true)
      expect(build(:animal).get_hungrier(100).ailing?).to be(true)
      expect(build(:animal).tap { |a| a.injure(85) }.ailing?).to be(true)
    end

    it '肺炎のまま死亡した個体は false を返すこと' do
      expect(build(:animal).tap { |a| a.fall_ill(IllnessCatalog.pneumonia) }.die.ailing?).to be(false)
    end
  end

  describe '#fed_today?' do
    it 'take_meal([:meat]) 前は false、後は true を返すこと' do
      animal = build(:animal)
      expect { animal.take_meal([:meat]) }.to change(animal, :fed_today?).from(false).to(true)
    end
  end

  describe '#settle_nutrition' do
    it 'ライオン(必要1カテゴリ)が [:meat] を食べた日は nutrition_level が 50 から 70 に上がり、meals が空に戻ること' do
      animal = build(:animal).tap { |a| a.nutrition = Animal::Nutrition.new(50) }
      animal.take_meal([:meat])
      expect { animal.settle_nutrition }.to change { animal.nutrition_level }.from(50).to(70)
      expect(animal.meals).to eq(Animal::Meals.none)
    end

    it '何も食べなかった日は nutrition_level が 100 から 75 に下がること' do
      animal = build(:animal)
      expect { animal.settle_nutrition }.to change { animal.nutrition_level }.from(100).to(75)
    end

    it '死亡個体は nutrition_level が変わらないこと' do
      animal = build(:animal).die
      expect { animal.settle_nutrition }.not_to(change { animal.nutrition_level })
    end
  end

  describe '保存と再読込' do
    def reloaded(animal)
      animal.save!
      Animal.find(animal.id)
    end

    it '体力60/100・空腹度35・ストレス50で保存すると、再読込後も同じ値であること' do
      animal = build(:animal)
      animal.injure(40).get_hungrier(35).add_stress(50)
      restored = reloaded(animal)
      expect(restored.current_health).to eq(60)
      expect(restored.max_health).to eq(100)
      expect(restored.hunger_level).to eq(35)
      expect(restored.stress_level).to eq(50)
    end

    it '肺炎にかかり風邪の免疫を持つ個体は、再読込後も肺炎で風邪に免疫があること' do
      animal = build(:animal).fall_ill(IllnessCatalog.cold).recover.fall_ill(IllnessCatalog.pneumonia)
      restored = reloaded(animal)
      expect(restored.illness).to eq(IllnessCatalog.pneumonia)
      expect(restored.immune_to?(IllnessCatalog.cold)).to be(true)
    end

    it '老衰で死亡した個体は、再読込後も死亡していて死因が :old_age であること' do
      restored = reloaded(build(:animal).die(cause: :old_age))
      expect(restored).to be_dead
      expect(restored.cause_of_death).to eq(:old_age)
    end

    it '[:meat] を食べた日の食事は、再読込後も meals.categories が [:meat] であること' do
      restored = reloaded(build(:animal).take_meal([:meat]))
      expect(restored.meals.categories).to eq([:meat])
      expect(restored.nutrition_level).to eq(100)
    end

    it '妊娠中のメスは、再読込後も妊娠中で妊娠日数と近交係数が保たれること' do
      dam = build(:animal, :female).conceive(inbreeding: 0.25).gestate(3)
      restored = reloaded(dam)
      expect(restored).to be_expecting
      expect(restored.gestation_days).to eq(3)
      expect(restored.expected_offspring_inbreeding).to eq(0.25)
    end

    it '鳴き声は保存されず、再読込後は種の既定の声(ライオンはガオー)に戻ること' do
      animal = build(:animal)
      animal.change_voice('ニャー')
      expect(reloaded(animal).cry_out).to eq('ガオー')
    end

    it '両親を持つ個体は、再読込後も parents が両親であること' do
      sire = create(:animal, name: '父')
      dam = create(:animal, :female, name: '母')
      expect(reloaded(build(:animal, name: '仔', sire:, dam:)).parents).to contain_exactly(sire, dam)
    end
  end
end
