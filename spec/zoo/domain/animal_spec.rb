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
        it '親を渡さなければ parent_ids は空であること' do
          expect(build.parent_ids).to eq([])
        end

        it '片親のみ渡すと nil は除かれ、その親だけが記録されること' do
          sire = build(name: '父')
          cub = build(name: '仔', sire: sire, dam: nil)
          expect(cub.parent_ids).to eq([sire.id])
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

      describe '#parent_of? / #sibling_of?' do
        it '動物でない引数には false を返すこと' do
          animal = build
          expect(animal.parent_of?('x')).to be(false)
          expect(animal.sibling_of?(42)).to be(false)
        end
      end

      describe '#pull_events' do
        it '取得するとイベントバッファが空になること' do
          animal = build
          animal.change_name('New')
          expect(animal.pull_events.size).to eq(1)
          expect(animal.pull_events).to be_empty
        end
      end

      describe '.reconstitute' do
        def reconstitute(health:, hunger:, stress:, illness:, death:, immunities: [], parent_ids: [])
          Animal.reconstitute(
            id: Shared::Identifier.new, species: SpeciesCatalog.lion,
            name: Animal::Name.new('レオ'), sex: Animal::Sex.male,
            health: health, hunger: hunger, age_in_days: Animal::AgeInDays.new(365 * 5),
            illness: illness, death: death, parent_ids: parent_ids,
            stress: stress, immunities: immunities
          )
        end

        it '体力・空腹・ストレスを保存値そのままに復元すること' do
          animal = reconstitute(
            health: Animal::Health.full(100).decreased_by(40),
            hunger: Animal::Hunger.new(35), stress: Animal::Stress.new(50),
            illness: nil, death: nil
          )
          expect(animal.current_health).to eq(60)
          expect(animal.hunger.level).to eq(35)
          expect(animal.stress.level).to eq(50)
        end

        it '病気と免疫を復元すること' do
          animal = reconstitute(
            health: Animal::Health.full(100), hunger: Animal::Hunger.satisfied,
            stress: Animal::Stress.calm, illness: illnesses.pneumonia, death: nil,
            immunities: [illnesses.cold]
          )
          expect(animal).to be_sick
          expect(animal.illness).to eq(illnesses.pneumonia)
          expect(animal.immune_to?(illnesses.cold)).to be(true)
        end

        it '死亡状態を復元すること' do
          animal = reconstitute(
            health: Animal::Health.full(100), hunger: Animal::Hunger.satisfied,
            stress: Animal::Stress.calm, illness: nil, death: Animal::Death.new(cause: :old_age)
          )
          expect(animal).to be_dead
          expect(animal.death.cause).to eq(:old_age)
        end

        it '鳴き声は保存せず、種の既定の声に戻ること(ライオンはガオー)' do
          animal = reconstitute(
            health: Animal::Health.full(100), hunger: Animal::Hunger.satisfied,
            stress: Animal::Stress.calm, illness: nil, death: nil
          )
          expect(animal.cry_out).to eq('ガオー')
        end

        it '復元直後は未通知のイベントを持たないこと' do
          animal = reconstitute(
            health: Animal::Health.full(100), hunger: Animal::Hunger.satisfied,
            stress: Animal::Stress.calm, illness: nil, death: nil
          )
          expect(animal.pull_events).to be_empty
        end
      end
    end
  end
end
