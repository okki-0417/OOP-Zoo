# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Assignment do
      let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:tending) { Tending.new(keeper: keeper, enclosure: enclosure, occurred_on: 3) }

      describe '就任のみを束ねた場合' do
        let(:assignment) { described_class.new(tending) }

        it 'keeper / enclosure を就任イベントから引くこと' do
          expect(assignment.keeper_id).to eq(keeper.id)
          expect(assignment.enclosure_id).to eq(enclosure.id)
        end

        it '就任日を持ち、退任日は無く、現役であること' do
          expect(assignment.assigned_on).to eq(3)
          expect(assignment.relieved_on).to be_nil
          expect(assignment).to be_active
          expect(assignment).not_to be_relieved
        end
      end

      describe '退任を束ねた場合' do
        let(:assignment) { described_class.new(tending, Relieving.of(tending, occurred_on: 7)) }

        it '退任日を持ち、退任済みであること' do
          expect(assignment.assigned_on).to eq(3)
          expect(assignment.relieved_on).to eq(7)
          expect(assignment).to be_relieved
          expect(assignment).not_to be_active
        end
      end

      describe '#to_s' do
        it '名前を配属 の形で表されること' do
          expect(described_class.new(tending).to_s).to eq('田中をサバンナに配属')
        end
      end
    end
  end
end
