# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe EnclosureDischarge do
      let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:assignment) { EnclosureAssignment.new(keeper: keeper, enclosure: enclosure) }

      describe '.of' do
        it '就任イベントを閉じる退任イベントを生成すること' do
          discharge = described_class.of(assignment, occurred_on: 5)
          expect(discharge.assignment).to eq(assignment)
          expect(discharge.occurred_on).to eq(5)
        end
      end

      describe '集約の委譲' do
        it 'keeper / enclosure / keeper_id / enclosure_id を就任イベントから委譲すること' do
          discharge = described_class.of(assignment)
          expect(discharge.keeper).to eq(keeper)
          expect(discharge.enclosure).to eq(enclosure)
          expect(discharge.keeper_id).to eq(keeper.id)
          expect(discharge.enclosure_id).to eq(enclosure.id)
        end
      end

      describe '同一性と不変性' do
        it '同じ id の EnclosureDischarge は等価で hash が一致すること' do
          id = Shared::Identifier.new
          a = described_class.of(assignment, id: id)
          b = described_class.of(assignment, id: id)
          expect(a).to eq(b)
          expect(a.hash).to eq(b.hash)
        end

        it '生成後は frozen であること' do
          expect(described_class.of(assignment)).to be_frozen
        end
      end

      describe '#to_s' do
        it '名前を エリア の担当から外す の形で表されること' do
          expect(described_class.of(assignment).to_s).to eq('田中をサバンナの担当から外す')
        end
      end
    end
  end
end
