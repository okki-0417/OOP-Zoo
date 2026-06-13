# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Death do
  describe '.new' do
    it 'cause: :predation を渡すと cause が :predation を返すこと' do
      expect(described_class.new(cause: :predation).cause).to eq(:predation)
    end

    it 'cause を省略すると cause が :unknown を返すこと' do
      expect(described_class.new.cause).to eq(:unknown)
    end
  end

  describe '#to_s' do
    it 'cause をそのまま文字列にして返すこと(例: :old_age → "old_age")' do
      expect(described_class.new(cause: :old_age).to_s).to eq('old_age')
    end
  end

  describe '等価性' do
    it '同じ cause 同士は eq で等しいこと' do
      expect(described_class.new(cause: :old_age)).to eq(described_class.new(cause: :old_age))
    end

    it '異なる cause 同士は eq で等しくないこと' do
      expect(described_class.new(cause: :old_age)).not_to eq(described_class.new(cause: :predation))
    end
  end
end
