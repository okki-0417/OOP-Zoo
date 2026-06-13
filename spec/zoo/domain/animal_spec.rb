# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal do
  # 振る舞いの検証用に、声を上書きできるライオン個体を用意する。
  def build_animal(name: 'Jack', voice: 'Woof', max_health: 10, age_in_days: 0, sex: Zoo::Domain::Animal::Sex.male)
    described_class.new(
      species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
      name: name, sex: sex, voice: voice, max_health: max_health, age_in_days: age_in_days
    )
  end

  describe '.new' do
    it '親を指定すると parent_ids に親のIDが入ること' do
      sire = build_animal(name: 'Sire')
      dam = build_animal(name: 'Dam', sex: Zoo::Domain::Animal::Sex.female)
      cub = described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: 'Cub', sex: Zoo::Domain::Animal::Sex.male, max_health: 10,
        sire: sire, dam: dam
      )
      expect(cub.parent_ids).to contain_exactly(sire.id, dam.id)
    end
  end

  describe '#cry_out' do
    let(:animal) { build_animal(max_health: max_health) }
    let(:max_health) { 10 }

    it '定義された鳴き声を返すこと' do
      expect(animal.cry_out).to eq('Woof')
    end

    it '鳴き声が空文字の場合は"..."を返すこと' do
      animal.change_voice('')
      expect(animal.cry_out).to eq('...')
    end

    it '鳴くと体力が1減ること' do
      expect { animal.cry_out }.to change { animal.current_health }.by(-1)
    end

    it '体力が20%以下のときは弱い鳴き声を返すこと' do
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

    it '鳴き声を変更できること' do
      animal.change_voice('Meow')
      expect(animal.cry_out).to eq('Meow')
    end

    it '鳴き声を省略すると種の既定の鳴き声が使われること' do
      lion = described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: 'レオ', sex: Zoo::Domain::Animal::Sex.male, max_health: 100
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

    it '死んだ動物に対しての回復はエラーになること' do
      animal.die
      expect { animal.heal(3) }.to raise_error(ArgumentError)
    end
  end

  describe '#change_name' do
    let(:animal) { build_animal }

    it '名前を変更できること' do
      animal.change_name('Cat')
      expect(animal.name).to eq(Zoo::Domain::Animal::Name.new('Cat'))
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
      expect(animal.death.cause).to eq(:old_age)
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
      expect(animal.death.cause).to eq(:starvation)
    end
  end

  describe '#can_breed_with?' do
    def adult(sex, species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion)
      described_class.new(species: species, name: 'X', sex: sex, max_health: 100, age_in_days: 365 * 5)
    end

    let(:male) { adult(Zoo::Domain::Animal::Sex.male) }
    let(:female) { adult(Zoo::Domain::Animal::Sex.female) }

    it '同種・異性・成熟した個体同士はtrueを返すこと' do
      expect(male.can_breed_with?(female)).to be(true)
    end

    it '同性同士はfalseを返すこと' do
      expect(male.can_breed_with?(adult(Zoo::Domain::Animal::Sex.male))).to be(false)
    end

    it '異種はfalseを返すこと' do
      zebra_like = adult(Zoo::Domain::Animal::Sex.female, species: Zoo::Domain::Taxonomy::SpeciesCatalog.grevys_zebra)
      expect(male.can_breed_with?(zebra_like)).to be(false)
    end

    it '未成熟な個体はfalseを返すこと' do
      cub = described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: 'Cub', sex: Zoo::Domain::Animal::Sex.female, max_health: 100, age_in_days: 0
      )
      expect(male.can_breed_with?(cub)).to be(false)
    end
  end

  describe '#alive? / #dead?' do
    let(:animal) { build_animal }

    it '生成直後は alive? が true、dead? が false を返すこと' do
      expect(animal).to be_alive
      expect(animal).not_to be_dead
    end

    it 'die を呼んだ後は alive? が false、dead? が true を返すこと' do
      animal.die
      expect(animal).to be_dead
      expect(animal).not_to be_alive
    end
  end

  describe '#incapacitated?' do
    let(:animal) { build_animal(max_health: 3) }

    it '体力が残っていればfalseを返すこと' do
      expect(animal).not_to be_incapacitated
    end

    it '体力が0だとtrueを返すこと' do
      3.times { animal.cry_out }
      expect(animal).to be_incapacitated
    end

    it '死亡時はtrueを返すこと' do
      animal.die
      expect(animal).to be_incapacitated
    end
  end

  describe '#die' do
    let(:animal) { build_animal }

    it '呼ぶと dead? が true を返すようになること' do
      animal.die
      expect(animal).to be_dead
    end

    it 'cause: :predation を渡すと death.cause が :predation を返すこと' do
      animal.die(cause: :predation)
      expect(animal.death.cause).to eq(:predation)
    end

    it 'cause を省略すると death.cause が :unknown を返すこと' do
      animal.die
      expect(animal.death.cause).to eq(:unknown)
    end

    it '呼ぶと pull_events から AnimalDied が1件取り出せ、cause が指定値と一致すること' do
      animal.die(cause: :predation)
      events = animal.pull_events
      expect(events.size).to eq(1)
      expect(events.first).to be_a(Zoo::Domain::Events::AnimalDied)
      expect(events.first.cause).to eq(:predation)
    end

    it '2回目の die では death.cause が上書きされず、pull_events も空のままになること' do
      animal.die(cause: :predation)
      animal.pull_events
      animal.die(cause: :illness)
      expect(animal.pull_events).to be_empty
      expect(animal.death.cause).to eq(:predation)
    end
  end

  describe '#parent_of?' do
    let(:sire) { build_animal(name: 'Sire') }
    let(:dam) { build_animal(name: 'Dam', sex: Zoo::Domain::Animal::Sex.female) }
    let(:cub) do
      described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: 'Cub', sex: Zoo::Domain::Animal::Sex.male, max_health: 10,
        sire: sire, dam: dam
      )
    end

    it 'sire/dam に渡された個体は、その子を引数にすると true を返すこと' do
      expect(sire.parent_of?(cub)).to be(true)
      expect(dam.parent_of?(cub)).to be(true)
    end

    it 'parent_ids に含まれない個体を引数にすると false を返すこと' do
      stranger = build_animal(name: 'Stranger')
      expect(sire.parent_of?(stranger)).to be(false)
    end

    it 'Animal でない引数(String など)に対しては false を返すこと' do
      expect(sire.parent_of?('not an animal')).to be(false)
    end
  end

  describe '#sibling_of?' do
    let(:sire) { build_animal(name: 'Sire') }
    let(:dam) { build_animal(name: 'Dam', sex: Zoo::Domain::Animal::Sex.female) }
    def build_cub(name, sire:, dam:)
      described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: name, sex: Zoo::Domain::Animal::Sex.male, max_health: 10,
        sire: sire, dam: dam
      )
    end

    it 'sire と dam が両方同じ個体同士は true を返すこと' do
      a = build_cub('A', sire: sire, dam: dam)
      b = build_cub('B', sire: sire, dam: dam)
      expect(a.sibling_of?(b)).to be(true)
    end

    it 'sire だけ共通で dam が違っても true を返すこと(半きょうだい)' do
      other_dam = build_animal(name: 'OtherDam', sex: Zoo::Domain::Animal::Sex.female)
      a = build_cub('A', sire: sire, dam: dam)
      b = build_cub('B', sire: sire, dam: other_dam)
      expect(a.sibling_of?(b)).to be(true)
    end

    it 'sire も dam も別の個体だと false を返すこと' do
      other_sire = build_animal(name: 'OtherSire')
      other_dam = build_animal(name: 'OtherDam', sex: Zoo::Domain::Animal::Sex.female)
      a = build_cub('A', sire: sire, dam: dam)
      b = build_cub('B', sire: other_sire, dam: other_dam)
      expect(a.sibling_of?(b)).to be(false)
    end
  end

  describe '#fall_ill' do
    let(:animal) { build_animal(max_health: 100) }
    let(:cold) { Zoo::Domain::Medical::IllnessCatalog.cold }

    it 'cold を渡すと illness が cold を返し、sick? が true を返すようになること' do
      animal.fall_ill(cold)
      expect(animal).to be_sick
      expect(animal.illness).to eq(cold)
    end

    it 'illness を渡した文字列に変更すること' do
      animal.fall_ill('flu')
      expect(animal).to be_sick
      expect(animal.illness).to eq('flu')
    end

    it 'die 後に呼ぶと Errors::DeadAnimal が発生すること' do
      animal.die
      expect { animal.fall_ill(cold) }.to raise_error(Zoo::Domain::Errors::DeadAnimal)
    end
  end

  describe '#recover' do
    let(:animal) { build_animal(max_health: 100) }
    let(:cold) { Zoo::Domain::Medical::IllnessCatalog.cold }

    it 'fall_ill 後に呼ぶと illness が nil、sick? が false を返すようになること' do
      animal.fall_ill(cold)
      animal.recover
      expect(animal).not_to be_sick
      expect(animal.illness).to be_nil
    end

    it '病気でない個体に呼んでも例外にならないこと' do
      expect { animal.recover }.not_to raise_error
    end
  end

  describe '#sick?' do
    let(:animal) { build_animal(max_health: 100) }

    it '生成直後は false を返すこと' do
      expect(animal).not_to be_sick
    end

    it 'fall_ill 後は true を返すこと' do
      animal.fall_ill(Zoo::Domain::Medical::IllnessCatalog.cold)
      expect(animal).to be_sick
    end
  end

  describe '#get_hungrier' do
    let(:animal) { build_animal(max_health: 100) }

    it '20 を渡すと hunger.level が +20 されること' do
      expect { animal.get_hungrier(20) }.to change { animal.hunger.level }.by(20)
    end
  end

  describe '#eat' do
    let(:lion) { build_animal(max_health: 100) }
    let(:meat) { Zoo::Domain::Feeding::FoodCatalog.horse_meat } # 肉(satiety=35)
    let(:hay)  { Zoo::Domain::Feeding::FoodCatalog.hay }        # 植物

    before { lion.get_hungrier(80) }

    it 'lion(肉食)に horse_meat を渡すと hunger.level が satiety ぶん減ること' do
      expect { lion.eat(meat) }.to change { lion.hunger.level }.by(-meat.satiety)
    end

    it 'lion(肉食)に hay(植物)を渡すと Errors::IncompatibleFood が発生し、hunger.level は変わらないこと' do
      expect { lion.eat(hay) }.to raise_error(Zoo::Domain::Errors::IncompatibleFood)
      expect(lion.hunger.level).to eq(80)
    end

    it 'die 後に呼ぶと Errors::DeadAnimal が発生すること' do
      lion.die
      expect { lion.eat(meat) }.to raise_error(Zoo::Domain::Errors::DeadAnimal)
    end
  end

  describe '#fertile?' do
    def adult_lion(sex: Zoo::Domain::Animal::Sex.male, max_health: 100)
      described_class.new(
        species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
        name: 'X', sex: sex, max_health: max_health, age_in_days: 365 * 5
      )
    end

    it 'age=365*5(成体)・max_health 満タン・病気なし・生存中なら true を返すこと' do
      expect(adult_lion).to be_fertile
    end

    it 'die 後は false を返すこと' do
      lion = adult_lion
      lion.die
      expect(lion).not_to be_fertile
    end

    it 'age_in_days=0(未成熟)は false を返すこと' do
      cub = build_animal(age_in_days: 0)
      expect(cub).not_to be_fertile
    end

    it 'max_health=10 で cry_out を8回呼んで current_health=2(20%) にすると false を返すこと' do
      lion = adult_lion(max_health: 10)
      8.times { lion.cry_out }
      expect(lion).not_to be_fertile
    end

    it 'fall_ill 後は false を返すこと' do
      lion = adult_lion
      lion.fall_ill(Zoo::Domain::Medical::IllnessCatalog.cold)
      expect(lion).not_to be_fertile
    end
  end

  describe '#to_s' do
    it "build_animal(name: 'Jack') の戻り値が 'Jack(ライオン/オス/幼体)' になること" do
      animal = build_animal(name: 'Jack')
      expect(animal.to_s).to eq('Jack(ライオン/オス/幼体)')
    end
  end
end
