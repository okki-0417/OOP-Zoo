# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Assignment do
      let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end

      describe '#keeper_id / #enclosure_id' do
        it '保持する keeper / enclosure の id を返すこと' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(assignment.keeper_id).to eq(keeper.id)
          expect(assignment.enclosure_id).to eq(enclosure.id)
        end
      end

      describe '就任と退任の二元状態' do
        it '既定では現役(active? が真、relieved? が偽)であること' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(assignment).to be_active
          expect(assignment).not_to be_relieved
        end

        it 'relieved: true で生成すると退任済み(active? が偽)であること' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure, relieved: true)
          expect(assignment).to be_relieved
          expect(assignment).not_to be_active
        end
      end

      describe '#relieve' do
        it '自身を退任済みに変更して自身を返すこと' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(assignment.relieve).to be(assignment)
          expect(assignment).to be_relieved
        end
      end

      describe '同一性' do
        it '同じ id の Assignment は状態に関わらず等価で hash が一致すること' do
          id = Shared::Identifier.new
          active = described_class.new(keeper: keeper, enclosure: enclosure, id: id)
          relieved = described_class.new(keeper: keeper, enclosure: enclosure, relieved: true, id: id)
          expect(active).to eq(relieved)
          expect(active.hash).to eq(relieved.hash)
        end
      end

      describe '#to_s' do
        it '名前を配属 の形で表されること' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(assignment.to_s).to eq('田中をサバンナに配属')
        end
      end
    end
  end
end
