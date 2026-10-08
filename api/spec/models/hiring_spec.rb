# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hiring do
  subject(:hiring) { described_class.new(zoo:, employee:) }

  let(:zoo) { build(:zoo, funds: Money.yen(1_000_000)) }
  let(:employee) { build(:keeper, name: '田中') }

  describe '#perform' do
    context '飼育員を雇うとき' do
      it '飼育員の契約金だけ残高を減らすこと' do
        expect { hiring.perform }
          .to change(zoo, :balance).to(Balance.new(1_000_000 - Keeper.signing_fee.yen))
      end

      it '園と飼育員を保存し、その園の飼育員として返すこと' do
        expect(hiring.perform).to eq(employee)
        expect(zoo).to be_persisted
        expect(employee).to be_persisted.and have_attributes(zoo:)
      end
    end

    context '獣医を雇うとき' do
      let(:employee) { build(:veterinarian) }

      it '獣医の契約金だけ残高を減らすこと' do
        expect { hiring.perform }
          .to change(zoo, :balance).to(Balance.new(1_000_000 - Veterinarian.signing_fee.yen))
      end
    end

    context '残高が契約金に足りないとき' do
      let(:zoo) { build(:zoo, funds: Money.zero) }

      it 'InsufficientFunds を投げ、従業員を保存しないこと' do
        expect { hiring.perform }.to raise_error(Errors::InsufficientFunds)
        expect(employee).to be_new_record
      end
    end
  end

  describe '#to_s' do
    it '"田中を雇用" を返すこと' do
      expect(hiring.to_s).to eq('田中を雇用')
    end
  end
end
