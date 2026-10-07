# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Animal do
  let(:hill) { create(:enclosure, name: 'ライオンの丘') }

  it 'sex・lifeStage・health・hunger は成体のオスのライオンで "オス"・"成体"・100・0 を返すこと' do
    lion = build(:animal)

    expect(run_graphql_field('Animal.sex', lion)).to eq('オス')
    expect(run_graphql_field('Animal.lifeStage', lion)).to eq('成体')
    expect(run_graphql_field('Animal.health', lion)).to eq(100)
    expect(run_graphql_field('Animal.hunger', lion)).to eq(0)
  end

  it 'mealsToday は take_meal([:meat]) 後に [:meat](FoodCategory の MEAT)を返すこと' do
    meals = run_graphql_field('Animal.mealsToday', build(:animal).take_meal([:meat]))

    expect(meals).to eq([:meat])
    expect(Types::FoodCategory.coerce_isolated_result(meals.first)).to eq('MEAT')
  end

  it 'blemishes はストレス70の個体で [{ cause: :stressed(STRESSED), penalty: 40 }] を返すこと' do
    blemishes = run_graphql_field('Animal.blemishes', build(:animal).add_stress(70))

    expect(blemishes).to eq([{ cause: :stressed, penalty: 40 }])
    expect(Types::BlemishCause.coerce_isolated_result(:stressed)).to eq('STRESSED')
  end

  it 'parents は父と母を持つ仔で [父, 母] を返すこと' do
    sire = create(:animal, name: '父')
    dam = create(:animal, :female, name: '母')

    expect(run_graphql_field('Animal.parents', create(:animal, :newborn, sire:, dam:))).to contain_exactly(sire, dam)
  end

  context 'ライオンの丘に1頭で収容されているとき' do
    let(:lion) { create(:animal, enclosure: hill) }

    it 'enclosure はライオンの丘を返すこと' do
      expect(run_graphql_field('Animal.enclosure', lion)).to eq(hill)
    end

    it 'stressors は [{ cause: :loneliness(LONELINESS), amount: 12 }] を返すこと' do
      stressors = run_graphql_field('Animal.stressors', lion)

      expect(stressors).to eq([{ cause: :loneliness, amount: 12 }])
      expect(Types::StressorCause.coerce_isolated_result(:loneliness)).to eq('LONELINESS')
    end

    it 'prognosis・companionship・thermalSuitability はそれぞれ Prognosis・Companionship・ThermalSuitability を返すこと' do
      expect(run_graphql_field('Animal.prognosis', lion)).to be_a(Prognosis)
      expect(run_graphql_field('Animal.companionship', lion)).to be_a(Companionship)
      expect(run_graphql_field('Animal.thermalSuitability', lion)).to be_a(ThermalSuitability)
    end
  end

  context 'どのエリアにも収容されていないとき' do
    let(:lion) { create(:animal) }

    it 'stressors は [] を、prognosis・companionship・thermalSuitability は nil を返すこと' do
      expect(run_graphql_field('Animal.stressors', lion)).to eq([])
      expect(run_graphql_field('Animal.prognosis', lion)).to be_nil
      expect(run_graphql_field('Animal.companionship', lion)).to be_nil
      expect(run_graphql_field('Animal.thermalSuitability', lion)).to be_nil
    end
  end

  it 'enclosure はライオンの丘で死亡した個体では nil を返すこと' do
    lion = create(:animal, enclosure: hill)
    lion.die

    expect(run_graphql_field('Animal.enclosure', lion)).to be_nil
  end
end
