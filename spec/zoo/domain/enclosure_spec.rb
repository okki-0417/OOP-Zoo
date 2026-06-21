# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Enclosure do
      let(:savanna) do
        described_class.new(name: 'アフリカサバンナ', temperature: Shared::Temperature.celsius(30), capacity: 3)
      end

      it '広さを指定しなければ定員×100m²になること' do
        expect(savanna.area_sqm).to eq(300)
      end

      describe '清潔さ' do
        it 'soil で汚れ filthy? になり、clean で清掃できること' do
          savanna.soil(100)
          expect(savanna).to be_filthy
          savanna.clean(100)
          expect(savanna).not_to be_filthy
        end
      end

      describe '環境エンリッチメント' do
        it '新設エリアは刺激が満ちており殺風景でないこと' do
          expect(savanna).not_to be_barren
        end

        it 'deplete_enrichment で刺激が枯れると barren? になること' do
          savanna.deplete_enrichment(100)
          expect(savanna).to be_barren
        end

        it 'enrich で刺激を補充すると barren? が解けること' do
          savanna.deplete_enrichment(100)
          savanna.enrich(100)
          expect(savanna).not_to be_barren
        end
      end
    end
  end
end
