# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Occupancy do
  let(:lion) { SpeciesCatalog.lion }
  let(:zebra) { SpeciesCatalog.grevys_zebra }
  let(:giraffe) { SpeciesCatalog.reticulated_giraffe }

  def pen(name = '区画', capacity: 4, temp: 28)
    build(:enclosure, name:, temperature: Temperature.celsius(temp), capacity:)
  end

  describe '#full?' do
    it '占有数が定員に達すると満員になること' do
      enclosure = pen(capacity: 2)
      expect(Occupancy.new(enclosure: enclosure, occupants: [build(:animal, species: zebra, name: 'a')]).full?).to be(false)
      occupants = [build(:animal, species: zebra, name: 'a'), build(:animal, species: zebra, name: 'b')]
      expect(Occupancy.new(enclosure: enclosure, occupants: occupants).full?).to be(true)
    end
  end

  describe '#species_present_in' do
    it '占有個体の種を重複なく返すこと' do
      occupancy = Occupancy.new(enclosure: pen, occupants: [build(:animal, species: zebra, name: 'z'), build(:animal, species: giraffe, name: 'g')])
      expect(occupancy.species_present_in.size).to eq(2)
    end
  end

  describe '#required_area / #overcrowded?' do
    it '占有個体の必要面積を合計すること' do
      occupancy = Occupancy.new(enclosure: pen, occupants: [build(:animal, species: zebra, name: 'z1'), build(:animal, species: zebra, name: 'z2')])
      expect(occupancy.required_area).to eq(200.0)
    end

    it '空のエリアは過密でないこと' do
      expect(Occupancy.new(enclosure: pen(capacity: 2), occupants: []).overcrowded?).to be(false)
    end

    it '必要面積が広さを超えると過密であること' do
      expect(Occupancy.new(enclosure: pen(capacity: 1), occupants: [build(:animal, species: giraffe)]).overcrowded?).to be(true)
    end
  end
end
