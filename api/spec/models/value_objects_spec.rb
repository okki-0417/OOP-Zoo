# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Shared値オブジェクト' do
  describe Temperature do
    it '範囲内かどうかを判定できること' do
      range = described_class.celsius(-10)..described_class.celsius(5)
      expect(described_class.celsius(0).within?(range)).to be(true)
      expect(described_class.celsius(30).within?(range)).to be(false)
    end

    it '絶対零度未満はエラーになること' do
      expect { described_class.celsius(-300) }.to raise_error(ArgumentError)
    end

    it '華氏に換算できること(0℃=32°F、100℃=212°F)' do
      expect(described_class.celsius(0).fahrenheit).to eq(32)
      expect(described_class.celsius(100).fahrenheit).to eq(212)
    end
  end

  describe ValueObject do
    it '#components を実装しない値オブジェクトは NotImplementedError になること' do
      klass = Class.new { include ValueObject }
      expect { klass.new == klass.new }.to raise_error(NotImplementedError)
    end
  end
end
