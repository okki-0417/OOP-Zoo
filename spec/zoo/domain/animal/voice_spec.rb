# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Voice do
  describe '.new' do
    it "'Woof' を渡すと value が 'Woof' を返すこと" do
      expect(described_class.new('Woof').value).to eq('Woof')
    end

    it '空文字を渡すと silent? が true を返すこと' do
      expect(described_class.new('')).to be_silent
    end

    it 'nil を渡すと ArgumentError が発生すること' do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end
  end

  describe '.silent' do
    it 'value が空文字、silent? が true を返すこと' do
      voice = described_class.silent
      expect(voice.value).to eq('')
      expect(voice).to be_silent
    end
  end

  describe '.from' do
    it 'nil を渡すと silent と等しい Voice を返すこと' do
      expect(described_class.from(nil)).to eq(described_class.silent)
    end

    it "'Woof' を渡すと .new('Woof') と等しい Voice を返すこと" do
      expect(described_class.from('Woof')).to eq(described_class.new('Woof'))
    end
  end

  describe '#silent?' do
    it "value='Woof' の Voice は false を返すこと" do
      expect(described_class.new('Woof')).not_to be_silent
    end

    it "value='' の Voice は true を返すこと" do
      expect(described_class.new('')).to be_silent
    end
  end

  describe '#to_s' do
    it "value をそのまま返すこと(例: 'Woof' → 'Woof')" do
      expect(described_class.new('Woof').to_s).to eq('Woof')
    end
  end

  describe '等価性' do
    it '同じ文字列で生成した Voice 同士は eq で等しいこと' do
      expect(described_class.new('Woof')).to eq(described_class.new('Woof'))
    end

    it '.silent と .new(\'\') は eq で等しいこと' do
      expect(described_class.silent).to eq(described_class.new(''))
    end
  end
end
