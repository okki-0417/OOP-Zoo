# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '動物' do
  sex       = Zoo::Domain::Animal::Sex
  name_vo   = Zoo::Domain::Animal::Name
  catalog   = Zoo::Domain::SpeciesCatalog
  foods     = Zoo::Domain::FoodCatalog
  illnesses = Zoo::Domain::IllnessCatalog
  events    = Zoo::Domain::Events
  errors    = Zoo::Domain::Errors

  def build_animal(name: 'Jack', voice: 'Woof', max_health: 10, age_in_days: 0,
                   sex: Zoo::Domain::Animal::Sex.male)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: sex, voice: voice, max_health: max_health, age_in_days: age_in_days
    )
  end

  def adult_lion(sex: Zoo::Domain::Animal::Sex.male, max_health: 100,
                 species: Zoo::Domain::SpeciesCatalog.lion)
    Zoo::Domain::Animal.new(species: species, name: 'X', sex: sex, max_health: max_health, age_in_days: 365 * 5)
  end

  def build_cub(name, sire:, dam:)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::SpeciesCatalog.lion,
      name: name, sex: Zoo::Domain::Animal::Sex.male, max_health: 10, sire: sire, dam: dam
    )
  end

  describe '生死' do
    let(:animal) { build_animal }

    it '生まれた直後は生きていること' do
      expect(animal).to be_alive
      expect(animal).not_to be_dead
    end

    it '体力が残っていれば行動できること' do
      expect(build_animal(max_health: 3)).not_to be_incapacitated
    end

    context '体力が尽きると' do
      it '行動できなくなること' do
        animal = build_animal(max_health: 3)
        3.times { animal.cry_out }
        expect(animal).to be_incapacitated
      end
    end

    context '死ぬと' do
      it 'もう生きていないこと' do
        animal.die
        expect(animal).to be_dead
        expect(animal).not_to be_alive
      end

      it '行動できなくなること' do
        animal.die
        expect(animal).to be_incapacitated
      end

      it '死因(例: 捕食)が記録されること' do
        animal.die(cause: :predation)
        expect(animal.death.cause).to eq(:predation)
      end

      it '死因を指定しなければ不明として記録されること' do
        animal.die
        expect(animal.death.cause).to eq(:unknown)
      end

      it '死亡が一度だけできごととして通知されること' do
        animal.die(cause: :predation)
        recorded = animal.pull_events
        expect(recorded.size).to eq(1)
        expect(recorded.first).to be_a(events::AnimalDied)
        expect(recorded.first.cause).to eq(:predation)
      end

      it '二度は死なず、最初の死因と通知が保たれること' do
        animal.die(cause: :predation)
        animal.pull_events
        animal.die(cause: :illness)
        expect(animal.pull_events).to be_empty
        expect(animal.death.cause).to eq(:predation)
      end
    end
  end

  describe '体力' do
    let(:animal) { build_animal }

    before { 5.times { animal.cry_out } }

    context '手当てを受けると' do
      it '体力が回復すること' do
        expect { animal.heal(3) }.to change { animal.current_health }.by(3)
      end

      it '最大体力を超えては回復しないこと' do
        animal.heal(10)
        expect(animal.current_health).to eq(10)
      end

      it '回復後の体力が分かること' do
        expect(animal.heal(3)).to eq(8)
      end
    end

    context '体力が満タンのとき' do
      it 'それ以上は回復しないこと' do
        animal.heal(10)
        expect { animal.heal(5) }.not_to(change { animal.current_health })
      end
    end

    context '負の回復量を与えると' do
      it '手当てできないこと' do
        expect { animal.heal(-1) }.to raise_error(ArgumentError)
      end
    end

    context 'ゼロの回復量を与えると' do
      it '体力が変わらないこと' do
        expect { animal.heal(0) }.not_to(change { animal.current_health })
      end
    end

    context '死んでいるとき' do
      it '手当てできないこと' do
        animal.die
        expect { animal.heal(3) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '鳴き声' do
    let(:animal) { build_animal }

    it '与えられた声で鳴くこと' do
      expect(animal.cry_out).to eq('Woof')
    end

    it '声を変えると、その声で鳴くこと' do
      animal.change_voice('Meow')
      expect(animal.cry_out).to eq('Meow')
    end

    it '声を指定しなければ種の既定の声で鳴くこと(ライオンはガオー)' do
      lion = Zoo::Domain::Animal.new(species: catalog.lion, name: 'レオ', sex: sex.male, max_health: 100)
      expect(lion.cry_out).to eq('ガオー')
    end

    it '鳴くと体力を少し消耗すること' do
      expect { animal.cry_out }.to change { animal.current_health }.by(-1)
    end

    context '声を持たないとき' do
      it '鳴かないこと' do
        animal.change_voice('')
        expect(animal.cry_out).to eq('...')
      end
    end

    context '衰弱しているとき' do
      it '体力が2割以下だと弱々しい声になること' do
        8.times { animal.cry_out }
        expect(animal.cry_out).to eq('Woof...')
      end
    end

    context '体力が尽きているとき' do
      it '鳴けないこと' do
        10.times { animal.cry_out }
        expect(animal.cry_out).to eq('...')
      end
    end
  end

  describe '空腹と飢餓' do
    let(:animal) { build_animal(max_health: 100) }
    let(:meat) { foods.horse_meat }
    let(:hay)  { foods.hay }

    context '時間が経つと' do
      it '空腹が進むこと' do
        animal.grow_older(7)
        expect(animal).to be_hungry
      end
    end

    context '空腹を満たすと' do
      it 'もう空腹ではないこと' do
        animal.grow_older(7)
        animal.satisfy_hunger(100)
        expect(animal).not_to be_hungry
      end
    end

    context '食性に合う餌を食べると' do
      it '満腹度が餌のぶんだけ回復すること' do
        animal.get_hungrier(80)
        expect { animal.eat(meat) }.to change { animal.hunger.level }.by(-meat.satiety)
      end
    end

    context '食性に合わない餌を与えられると' do
      it '受け付けず、空腹も変わらないこと' do
        animal.get_hungrier(80)
        expect { animal.eat(hay) }.to raise_error(errors::IncompatibleFood)
        expect(animal.hunger.level).to eq(80)
      end
    end

    context '死んでいるとき' do
      it '餌を食べられないこと' do
        animal.die
        expect { animal.eat(meat) }.to raise_error(errors::DeadAnimal)
      end
    end

    context '飢餓のまま放置されると' do
      it '衰弱し、やがて餓死すること' do
        animal.grow_older(10)
        expect(animal).to be_starving
        animal.grow_older(60)
        expect(animal).to be_dead
        expect(animal.death.cause).to eq(:starvation)
      end
    end
  end

  describe '加齢とライフステージ' do
    it '生まれたては幼体であること' do
      expect(build_animal(age_in_days: 0).life_stage).to be_baby
    end

    it '性成熟年齢(3歳)を過ぎると成体になること' do
      animal = build_animal(age_in_days: 0)
      animal.grow_older(365 * 3)
      expect(animal.life_stage).to be_adult
    end

    it '性成熟年齢(3歳)を過ぎると繁殖できる年齢になること' do
      animal = build_animal(age_in_days: 0)
      animal.grow_older(365 * 3)
      expect(animal.mature?).to be(true)
    end

    it '寿命(15年)を超えると寿命死すること' do
      animal = build_animal(max_health: 100)
      animal.grow_older(365 * 16)
      expect(animal).to be_dead
      expect(animal.death.cause).to eq(:old_age)
    end
  end

  describe '病気' do
    let(:animal) { build_animal(max_health: 100) }

    it '生まれた直後は健康であること' do
      expect(animal).not_to be_sick
    end

    it '病気でなければ治療しても何も起こらないこと' do
      expect { animal.recover }.not_to raise_error
    end

    context '発病すると' do
      it '病気にかかった状態になること' do
        animal.fall_ill(illnesses.cold)
        expect(animal).to be_sick
        expect(animal.illness).to eq(illnesses.cold)
      end

      it '治療を受けると回復すること' do
        animal.fall_ill(illnesses.cold)
        animal.recover
        expect(animal).not_to be_sick
        expect(animal.illness).to be_nil
      end
    end

    context '病気のまま放置されると' do
      it '体力を削られ、やがて病死すること' do
        animal.fall_ill(illnesses.pneumonia)
        animal.grow_older(20)
        expect(animal).to be_dead
        expect(animal.death.cause).to eq(:illness)
      end
    end

    context '死んでいるとき' do
      it '発病しないこと' do
        animal.die
        expect { animal.fall_ill(illnesses.cold) }.to raise_error(errors::DeadAnimal)
      end
    end
  end

  describe '福祉(ストレス)' do
    it '生まれた直後は穏やかで、ストレスを抱えていないこと' do
      expect(build_animal).not_to be_stressed
    end

    context '悪い状況でストレスを受けると' do
      it 'ストレス状態になること' do
        animal = build_animal
        animal.add_stress(70)
        expect(animal).to be_stressed
      end
    end

    context '状況が良くなりストレスが和らぐと' do
      it 'ストレス状態でなくなること' do
        animal = build_animal
        animal.add_stress(70)
        animal.relieve_stress(70)
        expect(animal).not_to be_stressed
      end
    end

    context '過度のストレス(9割以上)を抱えたまま日が過ぎると' do
      it '免疫が落ちて体力が削られること' do
        animal = build_animal(max_health: 100)
        animal.add_stress(90)
        expect { animal.grow_older(1) }.to change { animal.current_health }.by(-2)
      end
    end
  end

  describe '繁殖' do
    describe '繁殖できる状態か' do
      context '成熟し健康で生きているとき' do
        it '繁殖できること' do
          expect(adult_lion).to be_fertile
        end
      end

      context '死んでいるとき' do
        it '繁殖できないこと' do
          lion = adult_lion
          lion.die
          expect(lion).not_to be_fertile
        end
      end

      context 'まだ成熟していないとき' do
        it '繁殖できないこと' do
          expect(build_animal(age_in_days: 0)).not_to be_fertile
        end
      end

      context '衰弱しているとき' do
        it '体力が2割以下だと繁殖できないこと' do
          lion = adult_lion(max_health: 10)
          8.times { lion.cry_out }
          expect(lion).not_to be_fertile
        end
      end

      context '病気のとき' do
        it '繁殖できないこと' do
          lion = adult_lion
          lion.fall_ill(illnesses.cold)
          expect(lion).not_to be_fertile
        end
      end

      context 'ストレス過多のとき' do
        it '繁殖できないこと' do
          lion = adult_lion
          lion.add_stress(70)
          expect(lion).not_to be_fertile
        end
      end
    end

    describe '相手と交配できるか' do
      let(:male) { adult_lion(sex: sex.male) }
      let(:female) { adult_lion(sex: sex.female) }

      context '同じ種の異性で、双方が繁殖可能なとき' do
        it '交配できること' do
          expect(male.can_breed_with?(female)).to be(true)
        end
      end

      context '相手が同性のとき' do
        it '交配できないこと' do
          expect(male.can_breed_with?(adult_lion(sex: sex.male))).to be(false)
        end
      end

      context '相手が別の種のとき' do
        it '交配できないこと' do
          zebra = adult_lion(sex: sex.female, species: catalog.grevys_zebra)
          expect(male.can_breed_with?(zebra)).to be(false)
        end
      end

      context '相手がまだ成熟していないとき' do
        it '交配できないこと' do
          cub = Zoo::Domain::Animal.new(
            species: catalog.lion, name: 'Cub', sex: sex.female, max_health: 100, age_in_days: 0
          )
          expect(male.can_breed_with?(cub)).to be(false)
        end
      end
    end
  end

  describe '血縁' do
    let(:sire) { build_animal(name: 'Sire') }
    let(:dam) { build_animal(name: 'Dam', sex: sex.female) }

    it '親を指定して生まれると両親が血統として記録されること' do
      cub = build_cub('Cub', sire: sire, dam: dam)
      expect(cub.parent_ids).to contain_exactly(sire.id, dam.id)
    end

    describe '親子関係' do
      it '自分の子は親だと分かること' do
        cub = build_cub('Cub', sire: sire, dam: dam)
        expect(sire.parent_of?(cub)).to be(true)
        expect(dam.parent_of?(cub)).to be(true)
      end

      it '自分の子でなければ親ではないこと' do
        expect(sire.parent_of?(build_animal(name: 'Stranger'))).to be(false)
      end

      it '動物でないものは子ではないこと' do
        expect(sire.parent_of?('not an animal')).to be(false)
      end
    end

    describe 'きょうだい関係' do
      it '父母がともに同じならきょうだいであること' do
        a = build_cub('A', sire: sire, dam: dam)
        b = build_cub('B', sire: sire, dam: dam)
        expect(a.sibling_of?(b)).to be(true)
      end

      it '片方の親だけ同じでもきょうだいであること' do
        other_dam = build_animal(name: 'OtherDam', sex: sex.female)
        a = build_cub('A', sire: sire, dam: dam)
        b = build_cub('B', sire: sire, dam: other_dam)
        expect(a.sibling_of?(b)).to be(true)
      end

      it '父母がどちらも異なればきょうだいではないこと' do
        other_sire = build_animal(name: 'OtherSire')
        other_dam = build_animal(name: 'OtherDam', sex: sex.female)
        a = build_cub('A', sire: sire, dam: dam)
        b = build_cub('B', sire: other_sire, dam: other_dam)
        expect(a.sibling_of?(b)).to be(false)
      end
    end
  end

  describe '名前' do
    let(:animal) { build_animal }

    context '改名すると' do
      it '新しい名前になること' do
        animal.change_name('Cat')
        expect(animal.name).to eq(name_vo.new('Cat'))
      end

      it '改名されたことができごととして残ること' do
        animal.change_name('Cat')
        recorded = animal.pull_events
        expect(recorded.size).to eq(1)
        expect(recorded.first).to be_a(events::AnimalRenamed)
        expect(recorded.first.old_name).to eq('Jack')
        expect(recorded.first.new_name).to eq('Cat')
      end
    end
  end

  describe '見た目の表示' do
    it '名前・種・性別・ライフステージが分かる形で表されること' do
      expect(build_animal(name: 'Jack').to_s).to eq('Jack(ライオン/オス/幼体)')
    end
  end
end
