# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::HireKeeper do
  let(:funds) { 100_000 }
  let!(:zoo) { create(:zoo, funds: Money.yen(funds)) }

  def call_with(specialties: %w[mammal])
    command = Services::Commands::HireKeeperCommand.new(name: '田中', specialties:)
    described_class.new(command:).call
  end

  describe '#call' do
    it 'name=\'田中\' specialties=[\'mammal\'] で雇うと、result.value の id で find できる飼育員が保存されること' do
      keeper = call_with.value

      expect(Keeper.find(keeper.id).name).to eq('田中')
      expect(keeper.reload.specialties_label).to eq('哺乳類')
    end

    it '採用の一時金(20,000円)ぶん残高が減ること' do
      call_with

      expect(zoo.reload.balance).to eq(Balance.new(80_000))
    end

    it '空の specialties を渡すと result.error が RecordInvalid になり、飼育員は保存されず残高も変わらないこと' do
      result = call_with(specialties: [])

      expect(result.error).to be_a(ActiveRecord::RecordInvalid)
      expect(Keeper.count).to eq(0)
      expect(zoo.reload.balance).to eq(Balance.new(100_000))
    end

    it '未知の綱 specialties=[\'dragon\'] を渡すと TaxonClass の検証で ArgumentError が発生すること' do
      expect { call_with(specialties: %w[dragon]) }.to raise_error(ArgumentError)
    end

    context '残高が一時金に満たないとき' do
      let(:funds) { 10_000 }

      it 'result.error が InsufficientFunds になり、飼育員は保存されないこと' do
        result = call_with

        expect(result.error).to be_a(Errors::InsufficientFunds)
        expect(Keeper.count).to eq(0)
        expect(zoo.reload.balance).to eq(Balance.new(10_000))
      end
    end
  end
end
