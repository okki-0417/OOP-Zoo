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

  describe Zoo::Domain::Shared::Sex do
    it 'オス・メスを生成できること' do
      expect(described_class.male).to be_male
      expect(described_class.female).to be_female
    end

    it '異性かどうかを判定できること' do
      expect(described_class.male.opposite?(described_class.female)).to be(true)
      expect(described_class.male.opposite?(described_class.male)).to be(false)
    end

    it '未知の性別はエラーになること' do
      expect { described_class.new(:unknown) }.to raise_error(ArgumentError)
    end
  end

  describe Zoo::Domain::Shared::Weight do
    it 'kg/tから生成し相互変換できること' do
      expect(described_class.from_kilograms(2).grams).to eq(2000)
      expect(described_class.from_tons(3).kilograms).to eq(3000)
    end

    it '大小比較ができること' do
      expect(described_class.from_kilograms(2)).to be > described_class.from_grams(500)
    end

    it '加算できること' do
      expect((described_class.from_grams(300) + described_class.from_grams(200)).grams).to eq(500)
    end

    it '0以下はエラーになること' do
      expect { described_class.from_grams(0) }.to raise_error(ArgumentError)
    end

    it '人間に読みやすい単位で表示すること' do
      expect(described_class.from_tons(3).to_s).to eq('3.00t')
      expect(described_class.from_kilograms(2).to_s).to eq('2.0kg')
      expect(described_class.from_grams(50).to_s).to eq('50g')
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
