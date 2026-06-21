# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe '同居の相性' do
      let(:lion) { SpeciesCatalog.lion }
      let(:zebra) { SpeciesCatalog.grevys_zebra }
      let(:giraffe) { SpeciesCatalog.reticulated_giraffe }
      let(:polar_bear) { SpeciesCatalog.polar_bear }
      let(:penguin) { SpeciesCatalog.emperor_penguin }

      it '草食動物同士は混合展示できること' do
        expect(zebra.can_cohabit_with?(giraffe)).to be(true)
      end

      it '肉食動物は異種と同居できないこと' do
        expect(lion.can_cohabit_with?(zebra)).to be(false)
      end

      it '群れで暮らす種は同種を同居できること' do
        expect(lion.can_cohabit_with?(lion)).to be(true)
      end

      it '単独性の種は同種でも同居できないこと' do
        expect(polar_bear.can_cohabit_with?(polar_bear)).to be(false)
      end

      it '適温域が両立しない種同士は同居できないこと' do
        expect(lion.can_cohabit_with?(penguin)).to be(false)
      end
    end

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
