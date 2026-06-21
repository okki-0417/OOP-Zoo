# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '飼育密度と過密' do
  catalog = Zoo::Domain::SpeciesCatalog

  def pen(capacity, temp)
    Zoo::Domain::Enclosure.new(
      name: '区画', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: capacity
    )
  end

  describe '必要面積' do
    it '体の大きな種ほど広い面積を必要とすること' do
      expect(catalog.african_elephant.space_requirement_sqm).to be > catalog.lion.space_requirement_sqm
      expect(catalog.lion.space_requirement_sqm).to be > catalog.hercules_beetle.space_requirement_sqm
    end
  end

  describe '過密' do
    it '体格に見合う広さなら過密にならないこと' do
      enclosure = pen(4, 28)
      occupants = [build_adult(catalog.lion, name: 'A'), build_adult(catalog.lion, name: 'B')]
      occupancy = Zoo::Domain::Occupancy.new(enclosure, occupants)

      expect(occupancy.overcrowded?).to be(false)
    end

    it '必要面積の合計が区画の広さを超えると過密になること' do
      enclosure = pen(4, 25)
      occupants = [build_adult(catalog.african_elephant)]
      occupancy = Zoo::Domain::Occupancy.new(enclosure, occupants)

      expect(occupancy.overcrowded?).to be(true)
    end
  end
end
