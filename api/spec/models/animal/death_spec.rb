# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Death do
  subject(:death) { described_class.new(cause:) }

  let(:cause) { :old_age }

  describe '.new' do
    context 'cause: :predation のとき' do
      let(:cause) { :predation }

      it 'cause が :predation になること' do
        expect(death.cause).to eq(:predation)
      end
    end

    context 'cause を省略したとき' do
      subject(:death) { described_class.new }

      it 'cause が :unknown になること' do
        expect(death.cause).to eq(:unknown)
      end
    end
  end

  describe '#to_s' do
    it ':old_age の死因ラベル "老衰" を返すこと' do
      expect(death.to_s).to eq('老衰')
    end
  end

  describe '#==' do
    context '同じ cause :old_age のとき' do
      it '等しいこと' do
        expect(death).to eq(described_class.new(cause: :old_age))
      end
    end

    context 'cause が :old_age と :predation で違うとき' do
      it '等しくないこと' do
        expect(death).not_to eq(described_class.new(cause: :predation))
      end
    end
  end
end
