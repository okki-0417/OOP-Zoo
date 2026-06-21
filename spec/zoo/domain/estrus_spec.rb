# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Estrus do
      let(:lion) { SpeciesCatalog.lion }                 # 周年繁殖種
      let(:macaque) { SpeciesCatalog.japanese_macaque }  # 季節繁殖種(秋)
      let(:season) { Season }

      def female(species)
        build_adult(species, sex: Animal::Sex.female)
      end

      describe '#active?' do
        it '周年繁殖種のメスは、夏でも冬でも true を返すこと' do
          queen = female(lion)
          expect(described_class.new(queen, season.summer).active?).to be(true)
          expect(described_class.new(queen, season.winter).active?).to be(true)
        end

        it '季節繁殖種のメスは、繁殖季節(秋)で true・繁殖季節でない春で false を返すこと' do
          dam = female(macaque)
          expect(described_class.new(dam, season.autumn).active?).to be(true)
          expect(described_class.new(dam, season.spring).active?).to be(false)
        end
      end

      describe '.new' do
        it 'オスを渡すと ArgumentError(発情はメスにのみ起こります)を送出すること' do
          buck = build_adult(macaque, sex: Animal::Sex.male)
          expect { described_class.new(buck, season.autumn) }
            .to raise_error(ArgumentError, '発情はメスにのみ起こります')
        end
      end
    end
  end
end
