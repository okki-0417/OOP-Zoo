# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Animal do
      SpeciesCatalog.lion
      illnesses = IllnessCatalog

      def build(name: 'Jack', sex: Animal::Sex.male, max_health: 100, age_in_days: 0, sire: nil, dam: nil)
        Animal.new(
          species: SpeciesCatalog.lion, name: name, sex: sex,
          max_health: max_health, age_in_days: age_in_days, sire: sire, dam: dam
        )
      end

      describe '#initialize' do
        it '親を渡さなければ parents は空であること' do
          expect(build.parents).to eq([])
        end

        it '片親のみ渡すと nil は除かれ、その親だけが parents に記録されること' do
          sire = build(name: '父')
          cub = build(name: '仔', sire: sire, dam: nil)
          expect(cub.parents).to eq([sire])
        end
      end

      describe '#threatened?' do
        it '種の保全状況が危急(VU)のライオンでは true を返すこと' do
          expect(build.threatened?).to be(true)
        end

        it '種の保全状況が低危険(LC)のニホンザルでは false を返すこと' do
          macaque = Animal.new(
            species: SpeciesCatalog.japanese_macaque, name: 'Saru',
            sex: Animal::Sex.male, max_health: 100, age_in_days: 0
          )
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
          expect(build.tap { |a| a.fall_ill(illnesses.parasite) }.visible_condition).to eq(60)
        end

        it '衰弱した個体は VISIBLE_WEAK_PENALTY(20)引かれること' do
          expect(build.tap { |a| a.injure(85) }.visible_condition).to eq(80)
        end

        it '複数要因が重なっても0未満にはならないこと' do
          animal = build.tap do |a|
            a.add_stress(70)
            a.fall_ill(illnesses.parasite)
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
          expect(build.tap { |a| a.fall_ill(illnesses.cold) }.susceptible?).to be(false)
        end

        it '死亡していれば false を返すこと' do
          expect(build.tap(&:die).susceptible?).to be(false)
        end
      end

      describe '#contagious?' do
        it '感染性の病気(風邪)にかかっていれば true を返すこと' do
          expect(build.tap { |a| a.fall_ill(illnesses.cold) }.contagious?).to be(true)
        end

        it '非感染性の病気(骨折)では false を返すこと' do
          expect(build.tap { |a| a.fall_ill(illnesses.fracture) }.contagious?).to be(false)
        end

        it '健康なら false を返すこと' do
          expect(build.contagious?).to be(false)
        end

        it '感染性の病気を持っていても死亡していれば false を返すこと' do
          animal = build
          animal.fall_ill(illnesses.cold)
          animal.die
          expect(animal.contagious?).to be(false)
        end
      end

      describe '#contractible_illness' do
        it '免疫のない病気のうち最初のものを返すこと' do
          expect(build.contractible_illness([illnesses.cold, illnesses.pneumonia])).to eq(illnesses.cold)
        end

        it '免疫を持つ病気は飛ばし、罹りうる病気を返すこと' do
          animal = build.tap { |a| a.vaccinate(illnesses.cold) }
          expect(animal.contractible_illness([illnesses.cold, illnesses.pneumonia])).to eq(illnesses.pneumonia)
        end

        it 'すべての病気に免疫があれば nil を返すこと' do
          animal = build.tap { |a| a.vaccinate(illnesses.cold) }
          expect(animal.contractible_illness([illnesses.cold])).to be_nil
        end
      end

      describe '#dup' do
        it '複製の免疫を増やしても元の個体の免疫は増えないこと' do
          animal = build
          copy = animal.dup
          copy.fall_ill(illnesses.cold)
          copy.recover
          expect(animal.immunities).to eq([])
          expect(copy.immunities).to eq([illnesses.cold])
        end

        it '保存済みの個体を複製すると id を持たない新規の個体になり、元の個体とは等価でないこと' do
          animal = build.tap(&:save!)
          copy = animal.dup
          expect(copy).to be_new_record
          expect(copy).not_to eq(animal)
        end
      end

      describe '#days_until_starving' do
        it 'ライオン(1日+10)の空腹度95は1日、空腹度0は10日を返すこと' do
          expect(build.get_hungrier(95).days_until_starving).to eq(1)
          expect(build.days_until_starving).to eq(10)
        end
      end

      describe '#cause_of_death_label / #acceptable_food_categories' do
        it '老衰で死んだライオンは "老衰"、生きていれば nil を返すこと' do
          expect(build.die(cause: :old_age).cause_of_death_label).to eq('老衰')
          expect(build.cause_of_death_label).to be_nil
        end

        it 'ライオン(肉食)が食べられる餌の分類は [:meat] であること' do
          expect(build.acceptable_food_categories).to eq([:meat])
        end
      end

      describe '#take_meal' do
        it '[:meat] を2回 take_meal しても meals.categories は [:meat] のままであること' do
          animal = build
          animal.take_meal([:meat]).take_meal([:meat])
          expect(animal.meals.categories).to eq([:meat])
        end
      end

      describe '#ailing?' do
        it '健康なら false、肺炎(sick?)・空腹度100(starving?)・体力15/100(weak?)のいずれかなら true を返すこと' do
          expect(build.ailing?).to be(false)
          expect(build.tap { |a| a.fall_ill(illnesses.pneumonia) }.ailing?).to be(true)
          expect(build.get_hungrier(100).ailing?).to be(true)
          expect(build.tap { |a| a.injure(85) }.ailing?).to be(true)
        end

        it '肺炎のまま死亡した個体は false を返すこと' do
          expect(build.tap { |a| a.fall_ill(illnesses.pneumonia) }.die.ailing?).to be(false)
        end
      end

      describe '#fed_today?' do
        it 'take_meal([:meat]) 前は false、後は true を返すこと' do
          animal = build
          expect { animal.take_meal([:meat]) }.to change(animal, :fed_today?).from(false).to(true)
        end
      end

      describe '#settle_nutrition' do
        it 'ライオン(必要1カテゴリ)が [:meat] を食べた日は nutrition_level が 50 から 70 に上がり、meals が空に戻ること' do
          animal = build(age_in_days: 365 * 5).tap { |a| a.nutrition = Animal::Nutrition.new(50) }
          animal.take_meal([:meat])
          expect { animal.settle_nutrition }.to change { animal.nutrition_level }.from(50).to(70)
          expect(animal.meals).to eq(Animal::Meals.none)
        end

        it '何も食べなかった日は nutrition_level が 100 から 75 に下がること' do
          animal = build
          expect { animal.settle_nutrition }.to change { animal.nutrition_level }.from(100).to(75)
        end

        it '死亡個体は nutrition_level が変わらないこと' do
          animal = build.die
          expect { animal.settle_nutrition }.not_to(change { animal.nutrition_level })
        end
      end

      describe '保存と再読込' do
        def reloaded(animal)
          animal.save!
          Animal.find(animal.id)
        end

        it '体力60/100・空腹度35・ストレス50で保存すると、再読込後も同じ値であること' do
          animal = build(age_in_days: 365 * 5)
          animal.injure(40).get_hungrier(35).add_stress(50)
          restored = reloaded(animal)
          expect(restored.current_health).to eq(60)
          expect(restored.max_health).to eq(100)
          expect(restored.hunger_level).to eq(35)
          expect(restored.stress_level).to eq(50)
        end

        it '肺炎にかかり風邪の免疫を持つ個体は、再読込後も肺炎で風邪に免疫があること' do
          animal = build.fall_ill(illnesses.cold).recover.fall_ill(illnesses.pneumonia)
          restored = reloaded(animal)
          expect(restored.illness).to eq(illnesses.pneumonia)
          expect(restored.immune_to?(illnesses.cold)).to be(true)
        end

        it '老衰で死亡した個体は、再読込後も死亡していて死因が :old_age であること' do
          restored = reloaded(build.die(cause: :old_age))
          expect(restored).to be_dead
          expect(restored.cause_of_death).to eq(:old_age)
        end

        it '[:meat] を食べた日の食事は、再読込後も meals.categories が [:meat] であること' do
          restored = reloaded(build.take_meal([:meat]))
          expect(restored.meals.categories).to eq([:meat])
          expect(restored.nutrition_level).to eq(100)
        end

        it '妊娠中のメスは、再読込後も妊娠中で妊娠日数と近交係数が保たれること' do
          dam = build(sex: Animal::Sex.female, age_in_days: 365 * 5).conceive(inbreeding: 0.25).gestate(3)
          restored = reloaded(dam)
          expect(restored).to be_expecting
          expect(restored.gestation_days).to eq(3)
          expect(restored.expected_offspring_inbreeding).to eq(0.25)
        end

        it '鳴き声は保存されず、再読込後は種の既定の声(ライオンはガオー)に戻ること' do
          animal = build(age_in_days: 365 * 5)
          animal.change_voice('ニャー')
          expect(reloaded(animal).cry_out).to eq('ガオー')
        end

        it '両親を持つ個体は、再読込後も parents が両親であること' do
          sire = build(name: '父').tap(&:save!)
          dam = build(name: '母', sex: Animal::Sex.female).tap(&:save!)
          expect(reloaded(build(name: '仔', sire:, dam:)).parents).to contain_exactly(sire, dam)
        end
      end
    end
  end
end
