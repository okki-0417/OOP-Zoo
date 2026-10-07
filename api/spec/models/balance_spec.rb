# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Balance do
  describe '#+' do
    it 'Balance.zero + ¥5,000 は yen 5,000 を返すこと' do
      expect((described_class.zero + Money.yen(5_000)).yen).to eq(5_000)
    end
  end

  describe '#-' do
    subject(:balance) { described_class.new(1_000) - Money.yen(3_000) }

    context '残高 ¥1,000 を超える ¥3,000 を引いたとき' do
      it 'yen -2,000 の赤字になり、negative? が true を返すこと' do
        expect(balance.yen).to eq(-2_000)
        expect(balance).to be_negative
      end
    end
  end

  describe '#to_s' do
    context '赤字のとき' do
      it "符号付きの '-¥2,000' を返すこと" do
        expect((described_class.zero - Money.yen(2_000)).to_s).to eq('-¥2,000')
      end
    end
  end
end
