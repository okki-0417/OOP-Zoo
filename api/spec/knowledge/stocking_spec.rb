# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '飼育密度と過密' do
  def pen(capacity, temp)
    Enclosure.new(
      name: '区画', temperature: Temperature.celsius(temp), capacity: capacity
    )
  end

  describe '必要面積' do
    it '体の大きな種ほど広い面積を必要とすること' do
      expect(SpeciesCatalog.african_elephant.space_requirement_sqm).to be > SpeciesCatalog.lion.space_requirement_sqm
      expect(SpeciesCatalog.lion.space_requirement_sqm).to be > SpeciesCatalog.hercules_beetle.space_requirement_sqm
    end
  end

  describe '過密' do
    it '体格に見合う広さなら過密にならないこと' do
      enclosure = pen(4, 28)
      occupants = [build_adult(SpeciesCatalog.lion, name: 'A'), build_adult(SpeciesCatalog.lion, name: 'B')]
      occupancy = build_occupancy(enclosure, occupants)

      expect(occupancy.overcrowded?).to be(false)
    end

    it '必要面積の合計が区画の広さを超えると過密になること' do
      enclosure = pen(4, 25)
      occupants = [build_adult(SpeciesCatalog.african_elephant)]
      occupancy = build_occupancy(enclosure, occupants)

      expect(occupancy.overcrowded?).to be(true)
    end
  end
end
