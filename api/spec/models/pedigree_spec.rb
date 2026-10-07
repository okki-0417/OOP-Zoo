# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pedigree do
  subject(:pedigree) { described_class.new }

  let(:father) { build(:animal, name: '父') }
  let(:mother) { build(:animal, :female, name: '母') }
  let(:son) { build(:animal, :newborn, name: '兄', sire: father, dam: mother) }
  let(:daughter) { build(:animal, :newborn, :female, name: '妹', sire: father, dam: mother) }

  describe '#coancestry' do
    context 'どちらかが nil のとき' do
      it '(父, nil)・(nil, 父) のどちらも 0.0 を返すこと' do
        expect(pedigree.coancestry(father, nil)).to eq(0.0)
        expect(pedigree.coancestry(nil, father)).to eq(0.0)
      end
    end

    context '親の分からない個体同士のとき' do
      it '(父, 母) は 0.0 を返すこと' do
        expect(pedigree.coancestry(father, mother)).to eq(0.0)
      end
    end

    context '同じ個体同士のとき' do
      it '近交がない父と父は 0.5 を返すこと' do
        expect(pedigree.coancestry(father, father)).to eq(0.5)
      end
    end

    context '親子のとき' do
      it '(父, 兄) と (兄, 父) が同じ値を返すこと' do
        expect(pedigree.coancestry(father, son)).to eq(pedigree.coancestry(son, father))
      end
    end
  end

  describe '#inbreeding_of' do
    context '親が1頭しか分からないとき' do
      let(:child) { build(:animal, :newborn, name: '子', sire: nil, dam: mother) }

      it '0.0 を返すこと' do
        expect(pedigree.inbreeding_of(child)).to eq(0.0)
      end
    end

    context '両親が全きょうだい(兄と妹)のとき' do
      let(:child) { build(:animal, :newborn, name: '子', sire: son, dam: daughter) }

      it '1/4 の 0.25 を返すこと' do
        expect(pedigree.inbreeding_of(child)).to eq(0.25)
      end
    end
  end

  describe '#related?' do
    context '親の分からない創始個体同士のとき' do
      it '(父, 母) は false を返すこと' do
        expect(pedigree.related?(father, mother)).to be(false)
      end
    end

    context '親子のとき' do
      it '(父, 妹) は true を返すこと' do
        expect(pedigree.related?(father, daughter)).to be(true)
      end
    end

    context 'きょうだいのとき' do
      it '(兄, 妹) は true を返すこと' do
        expect(pedigree.related?(son, daughter)).to be(true)
      end
    end
  end

  describe '#mean_kinship' do
    context '個体が1頭以下のとき' do
      it '[父]・[] のどちらも 0.0 を返すこと' do
        expect(pedigree.mean_kinship([father])).to eq(0.0)
        expect(pedigree.mean_kinship([])).to eq(0.0)
      end
    end
  end
end
