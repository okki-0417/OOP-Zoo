# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Quarantine do
  subject(:quarantine) { described_class.new(days_observed) }

  let(:days_observed) { 5 }

  describe '.begin' do
    it '観察日数0で始まること' do
      expect(described_class.begin.days_observed).to eq(0)
    end
  end

  describe '.new' do
    context '観察日数が -1 のとき' do
      let(:days_observed) { -1 }

      it 'ArgumentError が発生すること' do
        expect { quarantine }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#observe' do
    context '観察5日に 3 を渡したとき' do
      it '観察8日の新しいインスタンスを返し、元は観察5日のままであること' do
        expect(quarantine.observe(3).days_observed).to eq(8)
        expect(quarantine.days_observed).to eq(5)
      end
    end

    context '0 を渡したとき' do
      it 'ArgumentError が発生すること' do
        expect { quarantine.observe(0) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#days_remaining' do
    context '観察日数が規定日数を超える 40 のとき' do
      let(:days_observed) { 40 }

      it '0 を返すこと' do
        expect(quarantine.days_remaining).to eq(0)
      end
    end
  end

  describe '#period_complete?' do
    context '観察日数が規定日数ちょうどの 30 のとき' do
      let(:days_observed) { 30 }

      it 'true を返すこと' do
        expect(quarantine.period_complete?).to be(true)
      end
    end

    context '観察日数が 29 のとき' do
      let(:days_observed) { 29 }

      it 'false を返すこと' do
        expect(quarantine.period_complete?).to be(false)
      end
    end
  end

  describe '#==' do
    let(:days_observed) { 7 }

    it '観察7日どうしは等しいこと' do
      expect(quarantine).to eq(described_class.new(7))
    end
  end
end
