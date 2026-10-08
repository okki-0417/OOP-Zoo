# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Constructing do
  subject(:constructing) { described_class.new(zoo:, enclosure:) }

  let(:zoo) { build(:zoo, funds: Money.yen(10_000_000)) }
  let(:climate_controlled) { false }
  let(:enclosure) { build(:enclosure, name: 'サバンナ', capacity: 4, climate_controlled:) }
  let(:cost) { Enclosure.construction_cost(capacity: 4, climate_controlled:) }

  describe '#perform' do
    context '空調なし・定員4のエリアのとき' do
      it '定員4・空調なしの建設費だけ残高を減らすこと' do
        expect { constructing.perform }.to change(zoo, :balance).to(Balance.new(10_000_000 - cost.yen))
      end

      it '園とエリアを保存し、その園のエリアとして返すこと' do
        expect(constructing.perform).to eq(enclosure)
        expect(zoo).to be_persisted
        expect(enclosure).to be_persisted.and have_attributes(zoo:)
      end
    end

    context '空調付きのエリアのとき' do
      let(:climate_controlled) { true }

      it '空調の追加費用を含めた建設費だけ残高を減らすこと' do
        expect { constructing.perform }.to change(zoo, :balance).to(Balance.new(10_000_000 - cost.yen))
      end
    end

    context '残高が建設費に足りないとき' do
      let(:zoo) { build(:zoo, funds: Money.zero) }

      it 'InsufficientFunds を投げ、エリアを保存しないこと' do
        expect { constructing.perform }.to raise_error(Errors::InsufficientFunds)
        expect(enclosure).to be_new_record
      end
    end
  end

  describe '#to_s' do
    it '"サバンナを建設" を返すこと' do
      expect(constructing.to_s).to eq('サバンナを建設')
    end
  end
end
