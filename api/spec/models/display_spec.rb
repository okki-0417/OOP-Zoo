# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '値オブジェクトの表示と比較' do
  describe '#to_s' do
    it 'Sex.male はラベルを返すこと' do
      expect(Animal::Sex.male.to_s).to eq(Animal::Sex.male.label)
    end

    it 'Season.spring はラベルを返すこと' do
      expect(Season.spring.to_s).to eq(Season.spring.label)
    end

    it 'LifeStage.baby は "幼体" を返すこと' do
      expect(Animal::LifeStage.baby.to_s).to eq('幼体')
    end

    it 'AgeInDays(100) は "100" を返すこと' do
      expect(Animal::AgeInDays.new(100).to_s).to eq('100')
    end

    it 'Health.full(50) は "50/50" を返すこと' do
      expect(Animal::Health.full(50).to_s).to eq('50/50')
    end

    it 'Hunger(20) は "20/100" を返すこと' do
      expect(Animal::Hunger.new(20).to_s).to eq('20/100')
    end

    it 'Cleanliness.spotless は "100/100" を返すこと' do
      expect(Enclosure::Cleanliness.spotless.to_s).to eq('100/100')
    end

    it 'Enrichment.stimulating は "100/100" を返すこと' do
      expect(Enclosure::Enrichment.stimulating.to_s).to eq('100/100')
    end

    it 'Reputation(30) は "30/100" を返すこと' do
      expect(Zoo::Reputation.new(30).to_s).to eq('30/100')
    end

    it 'ライオンの Species は "ライオン(Panthera leo)" を返すこと' do
      expect(SpeciesCatalog.lion.to_s).to eq('ライオン(Panthera leo)')
    end

    it 'ライオンの TaxonClass はラベルを返すこと' do
      expect(SpeciesCatalog.lion.taxon_class.to_s).to eq(SpeciesCatalog.lion.taxon_class.label)
    end

    it 'DietType.carnivore は "肉食" を返すこと' do
      expect(DietType.carnivore.to_s).to eq('肉食')
    end

    it 'ライオンの ConservationStatus は "VU(危急)" を返すこと' do
      expect(SpeciesCatalog.lion.conservation_status.to_s).to eq('VU(危急)')
    end

    it '馬肉の Food は "馬肉" を返すこと' do
      expect(FoodCatalog.horse_meat.to_s).to eq('馬肉')
    end
  end

  describe 'Reputation#<=>' do
    subject(:reputation) { Zoo::Reputation.new(10) }

    context '相手が Reputation のとき' do
      it 'スコアで比較し Reputation(10) < Reputation(20) であること' do
        expect(reputation).to be < Zoo::Reputation.new(20)
      end
    end

    context '相手が Reputation でないとき' do
      it '"x" との比較は nil を返すこと' do
        expect(reputation <=> 'x').to be_nil
      end
    end
  end
end
