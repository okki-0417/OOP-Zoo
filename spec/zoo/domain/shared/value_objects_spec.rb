# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Shared値オブジェクト' do
  describe Zoo::Domain::Shared::Identifier do
    it '省略するとUUIDを自動採番すること' do
      expect(described_class.new.value).to match(/\A[0-9a-f-]{36}\z/)
    end

    it '値が同じなら等しいこと' do
      expect(described_class.new('a1')).to eq(described_class.new('a1'))
    end

    it '空の識別子はエラーになること' do
      expect { described_class.new('') }.to raise_error(ArgumentError)
    end
  end

  describe Zoo::Domain::Shared::Temperature do
    it '範囲内かどうかを判定できること' do
      range = described_class.celsius(-10)..described_class.celsius(5)
      expect(described_class.celsius(0).within?(range)).to be(true)
      expect(described_class.celsius(30).within?(range)).to be(false)
    end

    it '絶対零度未満はエラーになること' do
      expect { described_class.celsius(-300) }.to raise_error(ArgumentError)
    end
  end
end
