# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Estrus do
  subject(:estrus) { described_class.new(animal, season) }

  let(:animal) { build(:animal, :female, species:) }
  let(:species) { SpeciesCatalog.lion }
  let(:season) { Season.summer }

  describe '.new' do
    context 'オスを渡したとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it "ArgumentError('発情はメスにのみ起こります') を投げること" do
        expect { estrus }.to raise_error(ArgumentError, '発情はメスにのみ起こります')
      end
    end
  end

  describe '#active?' do
    context '周年繁殖種(ライオン)のメスのとき' do
      it '夏・冬のどちらでも true を返すこと' do
        expect(described_class.new(animal, Season.summer).active?).to be(true)
        expect(described_class.new(animal, Season.winter).active?).to be(true)
      end
    end

    context '季節繁殖種(ニホンザル、繁殖季節は秋)のメスのとき' do
      let(:species) { SpeciesCatalog.japanese_macaque }

      context '秋のとき' do
        let(:season) { Season.autumn }

        it 'true を返すこと' do
          expect(estrus.active?).to be(true)
        end
      end

      context '春のとき' do
        let(:season) { Season.spring }

        it 'false を返すこと' do
          expect(estrus.active?).to be(false)
        end
      end
    end
  end
end
