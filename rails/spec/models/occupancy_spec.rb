# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Occupancy do
  describe '#full?' do
    it '占有数が定員に達すると満員になること' do
      enclosure = pen(capacity: 2)
      house_without_validation(build_adult(:grevys_zebra, name: 'a'), enclosure)
      expect(Occupancy.of(enclosure).full?).to be(false)

      house_without_validation(build_adult(:grevys_zebra, name: 'b'), enclosure)
      expect(Occupancy.of(enclosure).full?).to be(true)
    end
  end

  describe '#species_present_in' do
    it '占有個体の種を重複なく返すこと' do
      enclosure = pen
      house_without_validation(build_adult(:grevys_zebra, name: 'z'), enclosure)
      house_without_validation(build_adult(:reticulated_giraffe, name: 'g'), enclosure)
      expect(Occupancy.of(enclosure).species_present_in.size).to eq(2)
    end
  end

  describe '#required_area / #overcrowded?' do
    it '占有個体の必要面積を合計すること' do
      enclosure = pen
      house_without_validation(build_adult(:grevys_zebra, name: 'z1'), enclosure)
      house_without_validation(build_adult(:grevys_zebra, name: 'z2'), enclosure)
      expect(Occupancy.of(enclosure).required_area).to eq(200.0)
    end

    it '空のエリアは過密でないこと' do
      expect(Occupancy.of(pen(capacity: 2)).overcrowded?).to be(false)
    end

    it '必要面積が広さを超えると過密であること' do
      enclosure = pen(capacity: 1)
      house_without_validation(build_adult(:reticulated_giraffe), enclosure)
      expect(Occupancy.of(enclosure).overcrowded?).to be(true)
    end
  end
end
