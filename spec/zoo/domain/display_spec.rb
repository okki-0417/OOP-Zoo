# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe '値オブジェクトの表示と比較' do
      catalog = SpeciesCatalog

      describe '#to_s' do
        it 'Sex はラベルを返すこと' do
          expect(Animal::Sex.male.to_s).to eq(Animal::Sex.male.label)
        end

        it 'Season はラベルを返すこと' do
          expect(Season.spring.to_s).to eq(Season.spring.label)
        end

        it 'LifeStage はラベルを返すこと' do
          expect(Animal::LifeStage.baby.to_s).to eq('幼体')
        end

        it 'AgeInDays は日数を返すこと' do
          expect(Animal::AgeInDays.new(100).to_s).to eq('100')
        end

        it 'Health は 現在/最大 を返すこと' do
          expect(Animal::Health.full(50).to_s).to eq('50/50')
        end

        it 'Hunger は レベル/100 を返すこと' do
          expect(Animal::Hunger.new(20).to_s).to eq('20/100')
        end

        it 'Cleanliness は レベル/100 を返すこと' do
          expect(Cleanliness.spotless.to_s).to eq('100/100')
        end

        it 'Enrichment は レベル/100 を返すこと' do
          expect(Enrichment.stimulating.to_s).to eq('100/100')
        end

        it 'Reputation は スコア/100 を返すこと' do
          expect(Reputation.new(30).to_s).to eq('30/100')
        end

        it 'Species は 和名(学名) を返すこと' do
          expect(catalog.lion.to_s).to eq('ライオン(Panthera leo)')
        end

        it 'TaxonClass はラベルを返すこと' do
          expect(catalog.lion.taxon_class.to_s).to eq(catalog.lion.taxon_class.label)
        end

        it 'DietType はラベルを返すこと' do
          expect(catalog.lion.diet_type.to_s).to eq('肉食')
        end

        it 'ConservationStatus は コード(ラベル) を返すこと' do
          expect(catalog.lion.conservation_status.to_s).to eq('VU(危急)')
        end

        it 'Food は和名を返すこと' do
          expect(FoodCatalog.horse_meat.to_s).to eq('馬肉')
        end
      end

      describe 'Reputation#<=>' do
        it 'スコアの大小で比較されること' do
          expect(Reputation.new(10)).to be < Reputation.new(20)
        end

        it 'Reputation でない相手とは比較不能(nil)であること' do
          expect(Reputation.new(10) <=> 'x').to be_nil
        end
      end
    end
  end
end
