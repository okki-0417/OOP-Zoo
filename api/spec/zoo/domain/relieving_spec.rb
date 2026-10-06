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

      describe '.of' do
        it '閉じる Tending を保持すること' do
          expect(described_class.of(tending).tending).to eq(tending)
        end
      end

      describe '#violation!' do
        it '現に担当している(担当陣に居る)なら例外を出さないこと' do
          relieving = described_class.of(tending, assignment: Assignment.new(enclosure, [keeper]))
          expect { relieving.violation! }.not_to raise_error
        end

        it '担当陣に居なければ ReliefNotAllowed を出すこと' do
          relieving = described_class.of(tending, assignment: Assignment.new(enclosure, []))
          expect { relieving.violation! }
            .to raise_error(Errors::ReliefNotAllowed, /田中.*サバンナ.*退任/)
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
