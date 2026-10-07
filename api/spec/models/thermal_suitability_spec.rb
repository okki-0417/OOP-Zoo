# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ThermalSuitability do
  subject(:suitability) { described_class.new(animal, Temperature.celsius(celsius)) }

  let(:animal) { build(:animal) }
  let(:celsius) { 30 }

  describe '#habitable?' do
    context 'ライオンが30℃のとき' do
      it '適温域に入り true を返すこと' do
        expect(suitability.habitable?).to be(true)
      end
    end

    context 'ホッキョクグマが30℃のとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.polar_bear) }

      it '適温域を外れ false を返すこと' do
        expect(suitability.habitable?).to be(false)
      end
    end
  end

  describe '#comfortable?' do
    context 'ライオンが適温域の内側の25℃のとき' do
      let(:celsius) { 25 }

      it 'true を返すこと' do
        expect(suitability.comfortable?).to be(true)
      end
    end

    context 'ライオンが適温域の下端付近の12℃のとき' do
      let(:celsius) { 12 }

      it 'false を返すこと' do
        expect(suitability.comfortable?).to be(false)
      end
    end

    context 'ライオンが適温域を外れる50℃のとき' do
      let(:celsius) { 50 }

      it 'false を返すこと' do
        expect(suitability.comfortable?).to be(false)
      end
    end
  end
end
