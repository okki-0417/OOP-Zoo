# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '予後(日々の給餌は続け、治療も環境改善もしなかった場合の見通し)' do
  def lion_hill
    Enclosure.new(
      name: 'ライオンの丘', temperature: Temperature.celsius(25), capacity: 4
    )
  end

  def prognosis_of(animal, enclosure, occupants)
    Prognosis.new(
      animal:, enclosure:, occupancy: build_occupancy(enclosure, occupants), season: Season.spring
    )
  end

  def pride
    lion = SpeciesCatalog.lion
    [build_adult(lion, name: 'オス'), build_adult(lion, name: 'メス', sex: Animal::Sex.female)]
  end

  describe '良好な予後' do
    context '健康な成獣が清潔なエリアで群れと暮らしていると' do
      it '見通せる期間(30日)のうちに死亡する見込みはなく、予後は良好であること' do
        male, female = pride
        prognosis = prognosis_of(male, lion_hill, [male, female])

        expect(prognosis.days_to_death).to be_nil
        expect(prognosis.outlook).to eq(:good)
      end
    end
  end

  describe '病気の予後' do
    context '病気を治療しないままにすると' do
      it '病死が見込まれ、死因は病気であること' do
        male, female = pride
        male.fall_ill(IllnessCatalog.pneumonia)

        expect(prognosis_of(male, lion_hill, [male, female]).cause_of_death).to eq(:illness)
      end

      it '重い病気(肺炎)ほど、軽い病気(寄生虫)より早く死に至ること' do
        pneumonia_patient, female = pride
        pneumonia_patient.fall_ill(IllnessCatalog.pneumonia)
        parasite_patient = build_adult(SpeciesCatalog.lion, name: '寄生虫')
        parasite_patient.fall_ill(IllnessCatalog.parasite)

        pneumonia = prognosis_of(pneumonia_patient, lion_hill, [pneumonia_patient, female]).days_to_death
        parasite = prognosis_of(parasite_patient, lion_hill, [parasite_patient, female]).days_to_death

        expect(pneumonia).to be < parasite
      end

      it '2週間以内の死亡が見込まれるなら、予後は要注意であること' do
        male, female = pride
        male.fall_ill(IllnessCatalog.pneumonia)

        prognosis = prognosis_of(male, lion_hill, [male, female])
        expect(prognosis.days_to_death).to be <= 14
        expect(prognosis.outlook).to eq(:guarded)
      end
    end

    context '体力が残りわずかな個体が重い病気にかかっていると' do
      it '3日以内の死亡が見込まれ、危篤と判定されること' do
        weak = build_adult(SpeciesCatalog.lion, name: '瀕死', max_health: 10)
        weak.fall_ill(IllnessCatalog.pneumonia)
        female = build_adult(SpeciesCatalog.lion, name: 'メス', sex: Animal::Sex.female)

        expect(prognosis_of(weak, lion_hill, [weak, female]).outlook).to eq(:grave)
      end
    end
  end

  describe '環境が招く予後' do
    context '不潔なエリアに放置すると' do
      it '寄生虫のまん延が織り込まれ、健康な個体にも病死が見込まれること' do
        male, female = pride
        filthy = lion_hill.tap { |enclosure| enclosure.soil(80) }

        expect(prognosis_of(male, filthy, [male, female]).cause_of_death).to eq(:illness)
      end
    end

    context '序列下位のオスが優位なオスと同居し続けると' do
      it '闘争による外傷で死亡が見込まれること' do
        senior = build_animal(SpeciesCatalog.lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
        junior = build_adult(SpeciesCatalog.lion, name: '若', sex: Animal::Sex.male)

        expect(prognosis_of(junior, lion_hill, [senior, junior]).cause_of_death).to eq(:injury)
      end
    end
  end

  describe '寿命' do
    context '寿命が尽きかけている老齢個体は' do
      it '老衰による死亡が見込まれること' do
        elder = build_animal(SpeciesCatalog.lion, name: '長老', age_in_days: (SpeciesCatalog.lion.lifespan_years * 365) - 5)
        female = build_adult(SpeciesCatalog.lion, name: 'メス', sex: Animal::Sex.female)

        prognosis = prognosis_of(elder, lion_hill, [elder, female])
        expect(prognosis.cause_of_death).to eq(:old_age)
        expect(prognosis.days_to_death).to be <= 6
      end
    end
  end

  describe '見通しであること' do
    it '予後を見積もっても、実際の個体とエリアの状態は変わらないこと' do
      male, female = pride
      male.fall_ill(IllnessCatalog.pneumonia)
      enclosure = lion_hill

      expect { prognosis_of(male, enclosure, [male, female]).days_to_death }
        .not_to(change { [male.current_health, male.age_in_days, male.stress_level, enclosure.cleanliness_level] })
    end
  end

  describe '給餌が途絶えた場合' do
    it '満腹のライオン(1日に空腹度+10)は、給餌が途絶えると10日で飢餓に陥ること' do
      expect(build_adult(SpeciesCatalog.lion).days_until_starving).to eq(10)
    end

    it '代謝の速い種(フンボルトペンギン 1日+26)ほど早く飢餓に陥ること' do
      expect(build_adult(SpeciesCatalog.humboldt_penguin).days_until_starving).to eq(4)
    end

    it 'すでに飢餓状態なら0日であること' do
      lion = build_adult(SpeciesCatalog.lion).get_hungrier(100)
      expect(lion.days_until_starving).to eq(0)
    end
  end
end
