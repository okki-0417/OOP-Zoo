# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::AddEnclosure do
  let(:funds) { 100_000 }
  let!(:zoo) { create_zoo(funds:) }

  def add(name: 'ライオンの丘', celsius: 28, capacity: 4, climate_controlled: false)
    command = Services::Commands::AddEnclosureCommand.new(name:, celsius:, capacity:, climate_controlled:)
    described_class.new(command:).call
  end

  describe '#call' do
    it 'name "ライオンの丘" で建設すると、採番 id で find できるエリアが保存され、value がそのエリアであること' do
      enclosure = add.value

      expect(Enclosure.find(enclosure.id).name).to eq('ライオンの丘')
      expect(enclosure.capacity).to eq(4)
    end

    it '建設費(capacity 4 で 70,000円)ぶん残高が減ること' do
      add

      expect(zoo.reload.balance).to eq(Balance.new(30_000))
    end

    context '資金が 200,000円 のとき' do
      let(:funds) { 200_000 }

      it 'climate_controlled=true なら空調付きで建ち、建設費 70,000円 + 空調 50,000円 で残高 80,000円 になること' do
        enclosure = add(climate_controlled: true).value

        expect(enclosure.reload).to be_climate_controlled
        expect(zoo.reload.balance).to eq(Balance.new(80_000))
      end
    end

    it '空の name "" を渡すと result.error が RecordInvalid になり、エリアは保存されず残高も変わらないこと' do
      result = add(name: '')

      expect(result.error).to be_a(ActiveRecord::RecordInvalid)
      expect(Enclosure.count).to eq(0)
      expect(zoo.reload.balance).to eq(Balance.new(100_000))
    end

    context '残高(10,000円)が建設費に満たないとき' do
      let(:funds) { 10_000 }

      it 'failure になり error が InsufficientFunds で、エリアは保存されず残高も変わらないこと' do
        result = add

        expect(result.error).to be_a(Errors::InsufficientFunds)
        expect(Enclosure.count).to eq(0)
        expect(zoo.reload.balance).to eq(Balance.new(10_000))
      end
    end
  end
end
