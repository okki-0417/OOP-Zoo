# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::HireVeterinarian do
  let(:funds) { 100_000 }
  let!(:zoo) { create(:zoo, funds: Money.yen(funds)) }
  let(:service) do
    described_class.new(command: Services::Commands::HireVeterinarianCommand.new(name: '山田'))
  end

  describe '#call' do
    it 'name=\'山田\' で雇うと、result.value の id で find できる獣医が保存されること' do
      veterinarian = service.call.value

      expect(Veterinarian.find(veterinarian.id).name).to eq('山田')
    end

    it '採用の一時金(30,000円)ぶん残高が減ること' do
      service.call

      expect(zoo.reload.balance).to eq(Balance.new(70_000))
    end

    context '残高が一時金に満たないとき' do
      let(:funds) { 10_000 }

      it 'result.error が InsufficientFunds になり、獣医は保存されないこと' do
        result = service.call

        expect(result.error).to be_a(Errors::InsufficientFunds)
        expect(Veterinarian.count).to eq(0)
        expect(zoo.reload.balance).to eq(Balance.new(10_000))
      end
    end
  end
end
