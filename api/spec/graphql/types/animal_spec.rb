# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Animal do
  let(:lion) { build(:animal) }

  describe 'sex' do
    it 'オスのライオンで "オス" を返すこと' do
      expect(run_graphql_field('Animal.sex', lion)).to eq('オス')
    end
  end

  describe 'lifeStage' do
    it '成体のライオンで "成体" を返すこと' do
      expect(run_graphql_field('Animal.lifeStage', lion)).to eq('成体')
    end
  end

  describe 'health' do
    it '体力100のライオンで 100 を返すこと' do
      expect(run_graphql_field('Animal.health', lion)).to eq(100)
    end
  end

  describe 'hunger' do
    it '空腹度0のライオンで 0 を返すこと' do
      expect(run_graphql_field('Animal.hunger', lion)).to eq(0)
    end
  end

  describe 'mealsToday' do
    let(:lion) { build(:animal).take_meal([:meat]) }

    it 'take_meal([:meat]) した個体で [:meat](FoodCategory の MEAT)を返すこと' do
      meals = run_graphql_field('Animal.mealsToday', lion)

      expect(meals).to eq([:meat])
      expect(Types::FoodCategory.coerce_isolated_result(meals.first)).to eq('MEAT')
    end
  end

  describe 'blemishes' do
    let(:lion) { build(:animal).add_stress(70) }

    it 'ストレス70の個体で [{ cause: :stressed(STRESSED), penalty: 40 }] を返すこと' do
      expect(run_graphql_field('Animal.blemishes', lion)).to eq([{ cause: :stressed, penalty: 40 }])
      expect(Types::BlemishCause.coerce_isolated_result(:stressed)).to eq('STRESSED')
    end
  end

  describe 'parents' do
    let(:sire) { create(:animal, name: '父') }
    let(:dam) { create(:animal, :female, name: '母') }
    let(:lion) { create(:animal, :newborn, sire:, dam:) }

    it '[父, 母] を返すこと' do
      expect(run_graphql_field('Animal.parents', lion)).to contain_exactly(sire, dam)
    end
  end

  context 'ライオンの丘に1頭で収容されているとき' do
    let(:hill) { create(:enclosure, name: 'ライオンの丘') }
    let(:lion) { create(:animal, enclosure: hill) }

    describe 'enclosure' do
      it 'ライオンの丘を返すこと' do
        expect(run_graphql_field('Animal.enclosure', lion)).to eq(hill)
      end

      context '死亡しているとき' do
        before { lion.die }

        it 'nil を返すこと' do
          expect(run_graphql_field('Animal.enclosure', lion)).to be_nil
        end
      end
    end

    describe 'stressors' do
      it '[{ cause: :loneliness(LONELINESS), amount: 12 }] を返すこと' do
        expect(run_graphql_field('Animal.stressors', lion)).to eq([{ cause: :loneliness, amount: 12 }])
        expect(Types::StressorCause.coerce_isolated_result(:loneliness)).to eq('LONELINESS')
      end
    end

    describe 'prognosis' do
      it 'Prognosis を返すこと' do
        expect(run_graphql_field('Animal.prognosis', lion)).to be_a(Prognosis)
      end
    end

    describe 'companionship' do
      it 'Companionship を返すこと' do
        expect(run_graphql_field('Animal.companionship', lion)).to be_a(Companionship)
      end
    end

    describe 'thermalSuitability' do
      it 'ThermalSuitability を返すこと' do
        expect(run_graphql_field('Animal.thermalSuitability', lion)).to be_a(ThermalSuitability)
      end
    end
  end

  context 'どのエリアにも収容されていないとき' do
    let(:lion) { create(:animal) }

    describe 'stressors' do
      it '[] を返すこと' do
        expect(run_graphql_field('Animal.stressors', lion)).to eq([])
      end
    end

    describe 'prognosis' do
      it 'nil を返すこと' do
        expect(run_graphql_field('Animal.prognosis', lion)).to be_nil
      end
    end

    describe 'companionship' do
      it 'nil を返すこと' do
        expect(run_graphql_field('Animal.companionship', lion)).to be_nil
      end
    end

    describe 'thermalSuitability' do
      it 'nil を返すこと' do
        expect(run_graphql_field('Animal.thermalSuitability', lion)).to be_nil
      end
    end
  end
end
