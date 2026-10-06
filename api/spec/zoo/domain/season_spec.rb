# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Season do
  shared = Zoo::Domain::Shared

  describe '#temperature_offset' do
    it '夏は+8、冬は-8、春・秋は0であること' do
      expect(described_class.summer.temperature_offset).to eq(8)
      expect(described_class.winter.temperature_offset).to eq(-8)
      expect(described_class.spring.temperature_offset).to eq(0)
      expect(described_class.autumn.temperature_offset).to eq(0)
    end
  end

  describe '#felt_temperature' do
    it '区画の気温にオフセットを足して返すこと' do
      base = shared::Temperature.celsius(10)
      expect(described_class.winter.felt_temperature(base).celsius).to eq(2.0)
    end
  end

  describe '#initialize' do
    it '未知の季節は ArgumentError になること' do
      expect { described_class.new(:monsoon) }.to raise_error(ArgumentError)
    end
  end

  describe '.on_day' do
    it '四半期の境界で季節が切り替わること' do
      expect(described_class.on_day(0).value).to eq(:spring)
      expect(described_class.on_day(91).value).to eq(:summer)
      expect(described_class.on_day(182).value).to eq(:autumn)
      expect(described_class.on_day(273).value).to eq(:winter)
    end
  end
end
