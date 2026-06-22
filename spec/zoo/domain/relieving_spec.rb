# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Relieving do
      let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:tending) { Tending.new(keeper: keeper, enclosure: enclosure) }

      describe '.of / 委譲' do
        it '閉じる Tending から keeper / enclosure を引き継ぐこと' do
          relieving = described_class.of(tending)
          expect(relieving.tending).to eq(tending)
          expect(relieving.keeper_id).to eq(keeper.id)
          expect(relieving.enclosure_id).to eq(enclosure.id)
        end
      end

      describe '同一性と不変性' do
        it '同じ id の Relieving は等価で hash が一致すること' do
          id = Shared::Identifier.new
          a = described_class.of(tending, id: id)
          b = described_class.of(tending, id: id)
          expect(a).to eq(b)
          expect(a.hash).to eq(b.hash)
        end

        it '生成後は frozen であること' do
          expect(described_class.of(tending)).to be_frozen
        end
      end

      describe '#to_s' do
        it '担当から外す の形で表されること' do
          expect(described_class.of(tending).to_s).to eq('田中をサバンナの担当から外す')
        end
      end
    end
  end
end
