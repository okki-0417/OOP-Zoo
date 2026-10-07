# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Name do
  subject(:name) { described_class.new(value) }

  let(:value) { 'Jack' }

  describe '.new' do
    context "'Jack' を渡したとき" do
      it "value が 'Jack' になること" do
        expect(name.value).to eq('Jack')
      end
    end

    context '空文字を渡したとき' do
      let(:value) { '' }

      it 'ArgumentError を投げること' do
        expect { name }.to raise_error(ArgumentError)
      end
    end

    context 'nil を渡したとき' do
      let(:value) { nil }

      it 'ArgumentError を投げること' do
        expect { name }.to raise_error(ArgumentError)
      end
    end

    context '数値の 42 を渡したとき' do
      let(:value) { 42 }

      it "value が to_s した '42' になること" do
        expect(name.value).to eq('42')
      end
    end
  end

  describe '#to_s' do
    it "value の 'Jack' を返すこと" do
      expect(name.to_s).to eq('Jack')
    end
  end

  describe '#==' do
    it "'Jack' 同士の Name は等しいこと" do
      expect(name).to eq(described_class.new('Jack'))
    end

    it "'Jack' と 'Cat' の Name は等しくないこと" do
      expect(name).not_to eq(described_class.new('Cat'))
    end
  end

  describe '#hash' do
    it "'Jack' の Name をキーにした Hash を、別に作った 'Jack' の Name で引けること" do
      expect({ name => :ok }[described_class.new('Jack')]).to eq(:ok)
    end
  end
end
