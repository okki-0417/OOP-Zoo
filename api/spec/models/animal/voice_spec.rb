# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Voice do
  subject(:voice) { described_class.new(value) }

  let(:value) { 'Woof' }

  describe '.new' do
    context "'Woof' を渡したとき" do
      it "value が 'Woof' になること" do
        expect(voice.value).to eq('Woof')
      end
    end

    context 'nil を渡したとき' do
      let(:value) { nil }

      it 'ArgumentError を投げること' do
        expect { voice }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.silent' do
    subject(:voice) { described_class.silent }

    it "value が '' で、silent? が true の Voice を返すこと" do
      expect(voice.value).to eq('')
      expect(voice).to be_silent
    end
  end

  describe '.from' do
    subject(:voice) { described_class.from(value) }

    context 'nil を渡したとき' do
      let(:value) { nil }

      it '.silent と等しい Voice を返すこと' do
        expect(voice).to eq(described_class.silent)
      end
    end

    context "'Woof' を渡したとき" do
      it ".new('Woof') と等しい Voice を返すこと" do
        expect(voice).to eq(described_class.new('Woof'))
      end
    end
  end

  describe '#silent?' do
    context "value が 'Woof' のとき" do
      it 'false を返すこと' do
        expect(voice).not_to be_silent
      end
    end

    context "value が '' のとき" do
      let(:value) { '' }

      it 'true を返すこと' do
        expect(voice).to be_silent
      end
    end
  end

  describe '#to_s' do
    it "value の 'Woof' を返すこと" do
      expect(voice.to_s).to eq('Woof')
    end
  end

  describe '#==' do
    it "'Woof' 同士の Voice は等しいこと" do
      expect(described_class.new('Woof')).to eq(described_class.new('Woof'))
    end

    it ".silent と .new('') は等しいこと" do
      expect(described_class.silent).to eq(described_class.new(''))
    end
  end
end
