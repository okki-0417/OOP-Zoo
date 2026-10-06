# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe ThermalSuitability do
      let(:lion) { build_adult(SpeciesCatalog.lion, name: '主') }
      let(:polar_bear) { build_adult(SpeciesCatalog.polar_bear, name: '白') }

      def temp(celsius)
        Shared::Temperature.celsius(celsius)
      end

      describe '#habitable?' do
        it 'ライオン×30℃ で適温域に入り true を返すこと' do
          expect(described_class.new(lion, temp(30)).habitable?).to be(true)
        end

        it 'ホッキョクグマ×30℃ で適温域を外れ false を返すこと' do
          expect(described_class.new(polar_bear, temp(30)).habitable?).to be(false)
        end
      end

      describe '#comfortable?' do
        it 'ライオン×25℃ で適温域の内側として true を返すこと' do
          expect(described_class.new(lion, temp(25)).comfortable?).to be(true)
        end

        it 'ライオン×12℃ で適温域の下端付近として false を返すこと' do
          expect(described_class.new(lion, temp(12)).comfortable?).to be(false)
        end

        it 'ライオン×50℃ で適温域を外れ false を返すこと' do
          expect(described_class.new(lion, temp(50)).comfortable?).to be(false)
        end
      end
    end
  end
end
