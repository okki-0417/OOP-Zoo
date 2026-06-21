# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Occupancy do
      let(:lion) { SpeciesCatalog.lion }
      let(:zebra) { SpeciesCatalog.grevys_zebra }
      let(:giraffe) { SpeciesCatalog.reticulated_giraffe }

      def pen(name = '区画', capacity: 4, temp: 28)
        Enclosure.new(name: name, temperature: Shared::Temperature.celsius(temp), capacity: capacity)
      end

      describe '#full?' do
        it '占有数が定員に達すると満員になること' do
          enclosure = pen(capacity: 2)
          expect(described_class.new(enclosure, [build_adult(zebra, name: 'a')]).full?).to be(false)
          occupants = [build_adult(zebra, name: 'a'), build_adult(zebra, name: 'b')]
          expect(described_class.new(enclosure, occupants).full?).to be(true)
        end
      end

      describe '#species_present_in' do
        it '占有個体の種を重複なく返すこと' do
          occupancy = described_class.new(pen, [build_adult(zebra, name: 'z'), build_adult(giraffe, name: 'g')])
          expect(occupancy.species_present_in.size).to eq(2)
        end
      end

      describe '#required_area / #overcrowded?' do
        it '占有個体の必要面積を合計すること' do
          occupancy = described_class.new(pen, [build_adult(zebra, name: 'z1'), build_adult(zebra, name: 'z2')])
          expect(occupancy.required_area).to eq(200.0)
        end

        it '空のエリアは過密でないこと' do
          expect(described_class.new(pen(capacity: 2), []).overcrowded?).to be(false)
        end

        it '必要面積が広さを超えると過密であること' do
          expect(described_class.new(pen(capacity: 1), [build_adult(giraffe)]).overcrowded?).to be(true)
        end
      end
    end
  end
end
