# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Temperature do
  describe '.celsius' do
    context '絶対零度未満の -300 を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { described_class.celsius(-300) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#within?' do
    let(:range) { described_class.celsius(-10)..described_class.celsius(5) }

    it '-10℃..5℃ に対して、0℃は true・30℃は false を返すこと' do
      expect(described_class.celsius(0).within?(range)).to be(true)
      expect(described_class.celsius(30).within?(range)).to be(false)
    end
  end

  describe '#fahrenheit' do
    it '0℃は32°F・100℃は212°F を返すこと' do
      expect(described_class.celsius(0).fahrenheit).to eq(32)
      expect(described_class.celsius(100).fahrenheit).to eq(212)
    end
  end
end
