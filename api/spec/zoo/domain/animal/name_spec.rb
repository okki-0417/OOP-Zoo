# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Name do
  describe '.new' do
    it "'Jack' を渡すと value が 'Jack' を返すこと" do
      expect(described_class.new('Jack').value).to eq('Jack')
    end

    it '空文字を渡すと ArgumentError が発生すること' do
      expect { described_class.new('') }.to raise_error(ArgumentError)
    end

    it 'nil を渡すと ArgumentError が発生すること' do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it '数値などを渡しても to_s した文字列として保持されること' do
      expect(described_class.new(42).value).to eq('42')
    end
  end

  describe '#to_s' do
    it "value をそのまま返すこと(例: 'Jack' → 'Jack')" do
      expect(described_class.new('Jack').to_s).to eq('Jack')
    end
  end

  describe '等価性' do
    it '同じ文字列で生成した Name 同士は eq で等しいこと' do
      expect(described_class.new('Jack')).to eq(described_class.new('Jack'))
    end

    it '異なる文字列で生成した Name 同士は eq で等しくないこと' do
      expect(described_class.new('Jack')).not_to eq(described_class.new('Cat'))
    end

    it 'ハッシュのキーとして使えること(同値なら同じキー)' do
      a = described_class.new('Jack')
      b = described_class.new('Jack')
      expect({ a => :ok }[b]).to eq(:ok)
    end
  end
end
