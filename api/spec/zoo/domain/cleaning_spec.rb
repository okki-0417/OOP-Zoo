# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Cleaning do
      let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end

      describe '#perform' do
        it '保持するエリアの清潔さを amount=100 で満タンに戻すこと' do
          enclosure.soil(40)
          described_class.new(keeper: keeper, enclosure: enclosure).perform
          expect(enclosure.cleanliness.level).to eq(100)
        end

        it 'amount を指定するとその分だけ清潔さを回復すること' do
          enclosure.soil(100)
          described_class.new(keeper: keeper, enclosure: enclosure, amount: 30).perform
          expect(enclosure.cleanliness.level).to eq(30)
        end
      end

      describe 'keeper_id / enclosure_id' do
        it '保持する集約の id を返すこと' do
          cleaning = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(cleaning.keeper_id).to eq(keeper.id)
          expect(cleaning.enclosure_id).to eq(enclosure.id)
        end
      end

      describe '同一性と不変性' do
        it '同じ id の Cleaning は等価で hash が一致すること' do
          id = Shared::Identifier.new
          a = described_class.new(keeper: keeper, enclosure: enclosure, id: id)
          b = described_class.new(keeper: keeper, enclosure: enclosure, id: id)
          expect(a).to eq(b)
          expect(a.hash).to eq(b.hash)
        end

        it '生成後は frozen であること' do
          expect(described_class.new(keeper: keeper, enclosure: enclosure)).to be_frozen
        end
      end

      describe '#to_s' do
        it '飼育員がエリアを清掃 の形で表されること' do
          cleaning = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(cleaning.to_s).to eq('田中がサバンナを清掃')
        end
      end
    end
  end
end
