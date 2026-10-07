# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal do
  subject(:animal) { build(:animal, name: 'レオ') }

  describe '#parents' do
    context '親を渡さないとき' do
      it '空配列を返すこと' do
        expect(animal.parents).to eq([])
      end
    end

    context 'sire: 父・dam: nil を渡したとき' do
      subject(:animal) { build(:animal, sire:, dam: nil) }

      let(:sire) { build(:animal, name: '父') }

      it 'nil を除いた [父] を返すこと' do
        expect(animal.parents).to eq([sire])
      end
    end
  end

  describe '#move_to' do
    let(:hill) { build(:enclosure, name: '丘') }

    it 'enclosure を丘にすること' do
      expect(animal.move_to(hill).enclosure).to eq(hill)
    end
  end

  describe '#move_out' do
    context '丘に収容されているとき' do
      before { animal.move_to(build(:enclosure, name: '丘')) }

      it 'enclosure を nil に戻すこと' do
        expect(animal.move_out.enclosure).to be_nil
      end
    end

    context 'どのエリアにも収容されていないとき' do
      it '「レオはどのエリアにも収容されていません」の ArgumentError を投げること' do
        expect { animal.move_out }.to raise_error(ArgumentError, 'レオはどのエリアにも収容されていません')
      end
    end
  end

  describe '#threatened?' do
    context '保全状況が危急(VU)のライオンのとき' do
      it 'true を返すこと' do
        expect(animal.threatened?).to be(true)
      end
    end

    context '保全状況が低危険(LC)のニホンザルのとき' do
      subject(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it 'false を返すこと' do
        expect(animal.threatened?).to be(false)
      end
    end
  end

  describe '#age_in_years' do
    subject(:animal) { build(:animal, age_in_days: (365 * 4) + 200) }

    it '日齢 1660 を365で割って端数を切り捨てた 4 を返すこと' do
      expect(animal.age_in_years).to eq(4)
    end
  end

  describe '#to_s' do
    subject(:animal) { build(:animal, :newborn, name: 'Jack') }

    it '"Jack(ライオン/オス/幼体)" を返すこと' do
      expect(animal.to_s).to eq('Jack(ライオン/オス/幼体)')
    end
  end

  describe '#visible_condition' do
    context '健康で落ち着いているとき' do
      it '満点の 100 を返すこと' do
        expect(animal.visible_condition).to eq(100)
      end
    end

    context 'ストレス70を受けているとき' do
      before { animal.add_stress(70) }

      it 'VISIBLE_STRESSED_PENALTY(40) を引いた 60 を返すこと' do
        expect(animal.visible_condition).to eq(60)
      end
    end

    context '寄生虫症にかかっているとき' do
      before { animal.fall_ill(IllnessCatalog.parasite) }

      it 'VISIBLE_SICK_PENALTY(40) を引いた 60 を返すこと' do
        expect(animal.visible_condition).to eq(60)
      end
    end

    context '体力が15/100に衰弱しているとき' do
      before { animal.injure(85) }

      it 'VISIBLE_WEAK_PENALTY(20) を引いた 80 を返すこと' do
        expect(animal.visible_condition).to eq(80)
      end
    end

    context 'ストレス・病気・衰弱が重なっているとき' do
      before do
        animal.add_stress(70)
        animal.fall_ill(IllnessCatalog.parasite)
        animal.injure(85)
      end

      it '0未満にならず 0 を返すこと' do
        expect(animal.visible_condition).to eq(0)
      end
    end
  end

  describe '#susceptible?' do
    context '生きていて健康なとき' do
      it 'true を返すこと' do
        expect(animal.susceptible?).to be(true)
      end
    end

    context '風邪を発病しているとき' do
      before { animal.fall_ill(IllnessCatalog.cold) }

      it 'false を返すこと' do
        expect(animal.susceptible?).to be(false)
      end
    end

    context '死亡しているとき' do
      before { animal.die }

      it 'false を返すこと' do
        expect(animal.susceptible?).to be(false)
      end
    end
  end

  describe '#contagious?' do
    context '健康なとき' do
      it 'false を返すこと' do
        expect(animal.contagious?).to be(false)
      end
    end

    context '感染性の風邪にかかっているとき' do
      before { animal.fall_ill(IllnessCatalog.cold) }

      it 'true を返すこと' do
        expect(animal.contagious?).to be(true)
      end

      context 'さらに死亡したとき' do
        before { animal.die }

        it 'false を返すこと' do
          expect(animal.contagious?).to be(false)
        end
      end
    end

    context '非感染性の骨折をしているとき' do
      before { animal.fall_ill(IllnessCatalog.fracture) }

      it 'false を返すこと' do
        expect(animal.contagious?).to be(false)
      end
    end
  end

  describe '#contractible_illness' do
    let(:illnesses) { [IllnessCatalog.cold, IllnessCatalog.pneumonia] }

    context '免疫を持たないとき' do
      it '[風邪, 肺炎] のうち最初の風邪を返すこと' do
        expect(animal.contractible_illness(illnesses)).to eq(IllnessCatalog.cold)
      end
    end

    context '風邪に免疫を持つとき' do
      before { animal.vaccinate(IllnessCatalog.cold) }

      it '[風邪, 肺炎] のうち風邪を飛ばして肺炎を返すこと' do
        expect(animal.contractible_illness(illnesses)).to eq(IllnessCatalog.pneumonia)
      end

      context '候補が [風邪] だけのとき' do
        let(:illnesses) { [IllnessCatalog.cold] }

        it 'nil を返すこと' do
          expect(animal.contractible_illness(illnesses)).to be_nil
        end
      end
    end
  end

  describe '#dup' do
    let(:copy) { animal.dup }

    context '複製が風邪にかかって治ったとき' do
      before do
        copy.fall_ill(IllnessCatalog.cold)
        copy.recover
      end

      it '複製の免疫は [風邪] になり、元の個体の免疫は [] のままであること' do
        expect(copy.immunities).to eq([IllnessCatalog.cold])
        expect(animal.immunities).to eq([])
      end
    end

    context '保存済みの個体のとき' do
      subject(:animal) { create(:animal) }

      it 'id を持たない新規の個体を返し、元の個体とは等価でないこと' do
        expect(copy).to be_new_record
        expect(copy).not_to eq(animal)
      end
    end
  end

  describe '#days_until_starving' do
    context '空腹度0のライオン(1日+10)のとき' do
      it '10 を返すこと' do
        expect(animal.days_until_starving).to eq(10)
      end
    end

    context '空腹度95のライオン(1日+10)のとき' do
      before { animal.get_hungrier(95) }

      it '1 を返すこと' do
        expect(animal.days_until_starving).to eq(1)
      end
    end
  end

  describe '#cause_of_death_label' do
    context '生きているとき' do
      it 'nil を返すこと' do
        expect(animal.cause_of_death_label).to be_nil
      end
    end

    context '老衰で死んだとき' do
      before { animal.die(cause: :old_age) }

      it '"老衰" を返すこと' do
        expect(animal.cause_of_death_label).to eq('老衰')
      end
    end
  end

  describe '#acceptable_food_categories' do
    it '肉食のライオンでは [:meat] を返すこと' do
      expect(animal.acceptable_food_categories).to eq([:meat])
    end
  end

  describe '#take_meal' do
    it '[:meat] を2回食べても meals.categories は [:meat] のままであること' do
      animal.take_meal([:meat]).take_meal([:meat])

      expect(animal.meals.categories).to eq([:meat])
    end
  end

  describe '#ailing?' do
    context '健康なとき' do
      it 'false を返すこと' do
        expect(animal.ailing?).to be(false)
      end
    end

    context '肺炎(sick?)にかかっているとき' do
      before { animal.fall_ill(IllnessCatalog.pneumonia) }

      it 'true を返すこと' do
        expect(animal.ailing?).to be(true)
      end

      context 'さらに死亡したとき' do
        before { animal.die }

        it 'false を返すこと' do
          expect(animal.ailing?).to be(false)
        end
      end
    end

    context '空腹度100(starving?)のとき' do
      before { animal.get_hungrier(100) }

      it 'true を返すこと' do
        expect(animal.ailing?).to be(true)
      end
    end

    context '体力15/100(weak?)のとき' do
      before { animal.injure(85) }

      it 'true を返すこと' do
        expect(animal.ailing?).to be(true)
      end
    end
  end

  describe '#fed_today?' do
    it 'take_meal([:meat]) で false から true に変わること' do
      expect { animal.take_meal([:meat]) }.to change(animal, :fed_today?).from(false).to(true)
    end
  end

  describe '#settle_nutrition' do
    context '栄養50のライオン(必要1カテゴリ)が [:meat] を食べた日のとき' do
      before do
        animal.nutrition = Animal::Nutrition.new(50)
        animal.take_meal([:meat])
      end

      it 'nutrition_level を 50 から 70 に上げること' do
        expect { animal.settle_nutrition }.to change(animal, :nutrition_level).from(50).to(70)
      end

      it 'meals を Meals.none に戻すこと' do
        animal.settle_nutrition

        expect(animal.meals).to eq(Animal::Meals.none)
      end
    end

    context '何も食べなかった日のとき' do
      it 'nutrition_level を 100 から 75 に下げること' do
        expect { animal.settle_nutrition }.to change(animal, :nutrition_level).from(100).to(75)
      end
    end

    context '死亡しているとき' do
      before { animal.die }

      it 'nutrition_level を変えないこと' do
        expect { animal.settle_nutrition }.not_to change(animal, :nutrition_level)
      end
    end
  end

  describe '#conceive' do
    subject(:animal) { build(:animal, :female) }

    context 'オスのとき' do
      subject(:animal) { build(:animal) }

      it 'BreedingNotAllowed を投げること' do
        expect { animal.conceive }.to raise_error(Errors::BreedingNotAllowed)
      end
    end

    context '既に妊娠しているとき' do
      before { animal.conceive }

      it 'BreedingNotAllowed を投げること' do
        expect { animal.conceive }.to raise_error(Errors::BreedingNotAllowed)
      end
    end

    context '飢餓で流産した後、空腹が満たされたとき' do
      before do
        animal.conceive.get_hungrier(100).gestate(1)
        animal.satisfy_hunger(100)
      end

      it '再び受胎でき、miscarried? が false に戻り妊娠すること' do
        animal.conceive

        expect(animal).not_to be_miscarried
        expect(animal).to be_expecting
      end
    end
  end

  describe '#ready_to_deliver?' do
    subject(:animal) { build(:animal, :female) }

    before { animal.conceive.gestate(days) }

    context '受胎後、妊娠期間(ライオン)に1日足りないとき' do
      let(:days) { SpeciesCatalog.lion.gestation_period_days - 1 }

      it 'false を返すこと' do
        expect(animal).not_to be_ready_to_deliver
      end
    end

    context '受胎後、妊娠期間(ライオン)を満たしたとき' do
      let(:days) { SpeciesCatalog.lion.gestation_period_days }

      it 'true を返すこと' do
        expect(animal).to be_ready_to_deliver
      end
    end
  end

  describe '#gestate' do
    subject(:animal) { build(:animal, :female) }

    let(:hunger) { 0 }
    let(:stress) { 0 }

    before { animal.get_hungrier(hunger).add_stress(stress) }

    context '妊娠しておらず、空腹度100のとき' do
      let(:hunger) { 100 }

      it 'gestate(10) で流産しないこと' do
        animal.gestate(10)

        expect(animal).not_to be_miscarried
      end
    end

    context '妊娠中のとき' do
      before { animal.conceive }

      context '空腹度100(飢餓)のとき' do
        let(:hunger) { 100 }

        it 'gestate(1) で流産し、妊娠が解けること' do
          animal.gestate(1)

          expect(animal).to be_miscarried
          expect(animal).not_to be_expecting
        end
      end

      context 'ストレスが過度(SEVERE_THRESHOLD=90)のとき' do
        let(:stress) { Animal::Stress::SEVERE_THRESHOLD }

        it 'gestate(1) で流産すること' do
          animal.gestate(1)

          expect(animal).to be_miscarried
        end
      end

      context 'ストレスが過度の一歩手前(89)のとき' do
        let(:stress) { Animal::Stress::SEVERE_THRESHOLD - 1 }

        it 'gestate(1) で流産せず、妊娠が続くこと' do
          animal.gestate(1)

          expect(animal).not_to be_miscarried
          expect(animal).to be_expecting
        end
      end
    end
  end

  describe '#name_animal' do
    subject(:animal) { build(:animal, :female) }

    subject(:animal) { build(:animal, name: 'ライオンの赤ちゃん') }

    it "name_animal(name: 'ナラ') で name が 'ナラ' になること" do
      animal.name_animal(name: 'ナラ')

      expect(animal.name).to eq('ナラ')
    end
  end

  describe '保存と再読込' do
    let(:restored) { animal.tap(&:save!).then { |saved| described_class.find(saved.id) } }

    context '体力60/100・空腹度35・ストレス50のとき' do
      before { animal.injure(40).get_hungrier(35).add_stress(50) }

      it '再読込後も current_health 60・max_health 100・hunger_level 35・stress_level 50 であること' do
        expect(restored).to have_attributes(current_health: 60, max_health: 100, hunger_level: 35, stress_level: 50)
      end
    end

    context '風邪の免疫を持ち、肺炎にかかっているとき' do
      before { animal.fall_ill(IllnessCatalog.cold).recover.fall_ill(IllnessCatalog.pneumonia) }

      it '再読込後も illness が肺炎で、風邪に免疫があること' do
        expect(restored.illness).to eq(IllnessCatalog.pneumonia)
        expect(restored.immune_to?(IllnessCatalog.cold)).to be(true)
      end
    end

    context '老衰で死亡しているとき' do
      before { animal.die(cause: :old_age) }

      it '再読込後も死亡していて cause_of_death が :old_age であること' do
        expect(restored).to be_dead
        expect(restored.cause_of_death).to eq(:old_age)
      end
    end

    context '[:meat] を食べた日のとき' do
      before { animal.take_meal([:meat]) }

      it '再読込後も meals.categories が [:meat]・nutrition_level が 100 であること' do
        expect(restored.meals.categories).to eq([:meat])
        expect(restored.nutrition_level).to eq(100)
      end
    end

    context '近交係数0.25で受胎し妊娠3日目のメスのとき' do
      subject(:animal) { build(:animal, :female) }

      before { animal.conceive(inbreeding: 0.25).gestate(3) }

      it '再読込後も妊娠中で gestation_days 3・expected_offspring_inbreeding 0.25 であること' do
        expect(restored).to be_expecting
        expect(restored).to have_attributes(gestation_days: 3, expected_offspring_inbreeding: 0.25)
      end
    end

    context '鳴き声を "ニャー" に変えたとき' do
      before { animal.change_voice('ニャー') }

      it '鳴き声は保存されず、再読込後はライオンの既定の "ガオー" に戻ること' do
        expect(restored.cry_out).to eq('ガオー')
      end
    end

    context '両親を持つとき' do
      subject(:animal) { build(:animal, sire:, dam:) }

      let(:sire) { create(:animal, name: '父') }
      let(:dam) { create(:animal, :female, name: '母') }

      it '再読込後も parents が [父, 母] であること' do
        expect(restored.parents).to contain_exactly(sire, dam)
      end
    end
  end
end
