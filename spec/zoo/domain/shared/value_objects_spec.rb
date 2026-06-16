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

    it '華氏に換算できること(0℃=32°F、100℃=212°F)' do
      expect(described_class.celsius(0).fahrenheit).to eq(32)
      expect(described_class.celsius(100).fahrenheit).to eq(212)
    end
  end

  describe Zoo::Domain::Shared::ValueObject do
    it '#components を実装しない値オブジェクトは NotImplementedError になること' do
      klass = Class.new { include Zoo::Domain::Shared::ValueObject }
      expect { klass.new == klass.new }.to raise_error(NotImplementedError)
    end
  end

  describe Zoo::Domain::Shared::Entity do
    let(:entity_class) do
      Class.new do
        include Zoo::Domain::Shared::Entity

        attr_reader :id

        def initialize(id) = @id = id
      end
    end

    it 'id が同じなら hash が一致し、ハッシュキーとして同一視されること' do
      a = entity_class.new('x')
      b = entity_class.new('x')
      expect(a.hash).to eq(b.hash)
      expect({ a => 1 }[b]).to eq(1)
    end

    it 'id が異なれば等価でないこと' do
      expect(entity_class.new('x')).not_to eq(entity_class.new('y'))
    end
  end
end
