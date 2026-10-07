# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Season do
  describe '.new' do
    context '未知の季節 :monsoon を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { described_class.new(:monsoon) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.on_day' do
    it '0日目は春・91日目は夏・182日目は秋・273日目は冬と、四半期の境界で切り替わること' do
      expect(described_class.on_day(0).value).to eq(:spring)
      expect(described_class.on_day(91).value).to eq(:summer)
      expect(described_class.on_day(182).value).to eq(:autumn)
      expect(described_class.on_day(273).value).to eq(:winter)
    end
  end

  describe '#temperature_offset' do
    it '夏は+8・冬は-8・春と秋は0を返すこと' do
      expect(described_class.summer.temperature_offset).to eq(8)
      expect(described_class.winter.temperature_offset).to eq(-8)
      expect(described_class.spring.temperature_offset).to eq(0)
      expect(described_class.autumn.temperature_offset).to eq(0)
    end
  end

  describe '#felt_temperature' do
    it '冬に10℃を渡すと、オフセット-8を足した2.0℃を返すこと' do
      expect(described_class.winter.felt_temperature(Temperature.celsius(10)).celsius).to eq(2.0)
    end
  end
end
