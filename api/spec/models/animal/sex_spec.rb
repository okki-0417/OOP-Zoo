# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Sex do
  describe '.male / .female' do
    it '.male は male?、.female は female? が true であること' do
      expect(described_class.male).to be_male
      expect(described_class.female).to be_female
    end
  end

  describe '.new' do
    context '未知の性別 :unknown のとき' do
      it 'Errors::InvalidValue を投げること' do
        expect { described_class.new(:unknown) }.to raise_error(Errors::InvalidValue)
      end
    end
  end
end
