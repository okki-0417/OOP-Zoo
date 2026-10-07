# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Breeding do
  subject(:breeding) { described_class.new(sire:, dam:, day: 0, season:) }

  let(:species) { SpeciesCatalog.lion }
  let(:sire) { build(:animal, species:) }
  let(:dam) { build(:animal, :female, species:) }
  let(:season) { Season.spring }

  describe '#conceive' do
    context '同種の成獣のオスとメスのとき' do
      it 'Breeding 自身を返し、dam を妊娠させること' do
        expect(breeding.conceive).to be(breeding)
        expect(dam).to be_expecting
      end
    end

    context 'sire にメス・dam にオスを渡したとき' do
      let(:sire) { build(:animal, :female, species:) }
      let(:dam) { build(:animal, species:) }

      it 'BreedingNotAllowed を投げること' do
        expect { breeding.conceive }.to raise_error(Errors::BreedingNotAllowed)
      end
    end

    context 'dam がグレビーシマウマ(異種)のとき' do
      let(:dam) { build(:animal, :female, species: SpeciesCatalog.grevys_zebra) }

      it 'BreedingNotAllowed を投げること' do
        expect { breeding.conceive }.to raise_error(Errors::BreedingNotAllowed)
      end
    end

    context '周年繁殖種(ライオン)を夏に交配するとき' do
      let(:season) { Season.summer }

      it '例外を投げないこと' do
        expect { breeding.conceive }.not_to raise_error
      end
    end

    context '季節繁殖種(ニホンザル)を繁殖季節でない夏に交配するとき' do
      let(:species) { SpeciesCatalog.japanese_macaque }
      let(:season) { Season.summer }

      it 'BreedingNotAllowed を投げること' do
        expect { breeding.conceive }.to raise_error(Errors::BreedingNotAllowed)
      end
    end
  end
end
