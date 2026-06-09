# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal do
  # 振る舞いの検証用に、声を上書きできるライオン個体を用意する。
  def build_animal(name: 'Jack', voice: 'Woof', max_health: 10, age_in_days: 0, sex: Zoo::Domain::Shared::Sex.male)
    described_class.new(
      species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
      name: name, sex: sex, voice: voice, max_health: max_health, age_in_days: age_in_days
    )
  end

  describe '#cry_out' do
    let(:animal) { build_animal(max_health: max_health) }
    let(:max_health) { 10 }

    it '定義された音を返すこと' do
      expect(animal.cry_out).to eq('Woof')
    end

    it '鳴き声が空文字の場合は"..."を返すこと' do
      animal.change_voice('')
      expect(animal.cry_out).to eq('...')
    end

    it '鳴き声がnilの場合は"..."を返すこと' do
      silent = build_animal(name: 'Silent', voice: nil)
      expect(silent.cry_out).to eq('...')
    end

    it '鳴くと体力が1減ること' do
      expect { animal.cry_out }.to change { animal.current_health }.by(-1)
    end

    it '体力が20%以下のときは弱い音を返すこと' do
      (max_health * 0.8).to_i.times { animal.cry_out }
      expect(animal.cry_out).to eq('Woof...')
    end

    it '体力が0のときは"..."を返すこと' do
      max_health.times { animal.cry_out }
      expect(animal.cry_out).to eq('...')
    end
  end

  describe '#change_voice' do
    let(:animal) { build_animal }

    it '音を変更できること' do
      animal.change_voice('Meow')
      expect(animal.cry_out).to eq('Meow')
    end

    it '空の文字列に変更できること' do
      expect { animal.change_voice('') }.not_to raise_error
    end

    it 'nilには変更できないこと' do
      expect { animal.change_voice(nil) }.to raise_error(ArgumentError)
    end

    it '鳴き声を省略すると種の既定の鳴き声が使われること' do
      lion = described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: 'レオ', sex: Zoo::Domain::Shared::Sex.male, max_health: 100
      )
      expect(lion.cry_out).to eq('ガオー')
    end
  end

  describe '#heal' do
    let(:animal) { build_animal }

    before do
      5.times { animal.cry_out }
    end

    it '自分を回復できること' do
      expect { animal.heal(3) }.to change { animal.current_health }.by(3)
    end

    it '最大体力を回復しても最大体力を超えないこと' do
      animal.heal(10)
      expect(animal.current_health).to eq(10)
    end

    it '最大体力の時は回復しても体力が変わらないこと' do
      animal.heal(10)
      expect { animal.heal(5) }.not_to(change { animal.current_health })
    end

    it '回復した後の体力の値を返すこと' do
      expect(animal.heal(3)).to eq(8)
    end

    it 'マイナスの回復量が与えられたときはエラーになること' do
      expect { animal.heal(-1) }.to raise_error(ArgumentError)
    end

    it '0の回復量が与えられたときは体力が変わらないこと' do
      expect { animal.heal(0) }.not_to(change { animal.current_health })
    end

    it '死んだ動物は回復できないこと' do
      animal.die
      expect { animal.heal(3) }.to raise_error(ArgumentError)
    end
  end

  describe '#change_name' do
    let(:animal) { build_animal }

    it '名前がnilだとエラーになること' do
      expect { animal.change_name(nil) }.to raise_error(ArgumentError)
    end

    it '名前が空文字だとエラーになること' do
      expect { animal.change_name('') }.to raise_error(ArgumentError)
    end

    it '名前を変更できること' do
      animal.change_name('Cat')
      expect(animal.name).to eq('Cat')
    end
  end

  describe 'ライフステージと加齢' do
    it '生まれたては幼体で、性成熟年齢を超えると成体になること' do
      baby = build_animal(age_in_days: 0)
      expect(baby.life_stage).to be_baby
      # ライオンの性成熟は3歳。
      baby.grow_older(365 * 3)
      expect(baby.life_stage).to be_adult
      expect(baby.mature?).to be(true)
    end

    it '寿命を超えると寿命死すること' do
      animal = build_animal(max_health: 100)
      animal.grow_older(365 * 16) # ライオンの寿命は15年
      expect(animal).to be_dead
      expect(animal.cause_of_death).to eq(:old_age)
    end
  end

  describe '空腹と飢餓' do
    let(:animal) { build_animal(max_health: 100) }

    it '時間が経つと空腹になること' do
      animal.grow_older(7)
      expect(animal).to be_hungry
    end

    it '給餌すると空腹が満たされること' do
      animal.grow_older(7)
      animal.satisfy_hunger(100)
      expect(animal).not_to be_hungry
    end

    it '飢餓状態が続くと衰弱し、やがて餓死すること' do
      animal.grow_older(10) # 空腹度が上限に達する
      expect(animal).to be_starving
      animal.grow_older(60) # 飢餓のまま放置
      expect(animal).to be_dead
      expect(animal.cause_of_death).to eq(:starvation)
    end
  end

  describe '#can_breed_with?' do
    def adult(sex, species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion)
      described_class.new(species: species, name: 'X', sex: sex, max_health: 100, age_in_days: 365 * 5)
    end

    let(:male) { adult(Zoo::Domain::Shared::Sex.male) }
    let(:female) { adult(Zoo::Domain::Shared::Sex.female) }

    it '同種・異性・成熟した個体同士は繁殖できること' do
      expect(male.can_breed_with?(female)).to be(true)
    end

    it '同性同士は繁殖できないこと' do
      expect(male.can_breed_with?(adult(Zoo::Domain::Shared::Sex.male))).to be(false)
    end

    it '異種とは繁殖できないこと' do
      tiger_like = adult(Zoo::Domain::Shared::Sex.female, species: Zoo::Domain::Taxonomy::SpeciesCatalog.grevys_zebra)
      expect(male.can_breed_with?(tiger_like)).to be(false)
    end

    it '未成熟な個体は繁殖できないこと' do
      cub = described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: 'Cub', sex: Zoo::Domain::Shared::Sex.female, max_health: 100, age_in_days: 0
      )
      expect(male.can_breed_with?(cub)).to be(false)
    end
  end
end
