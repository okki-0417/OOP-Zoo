# frozen_string_literal: true

require 'spec_helper'

# 飼育密度の知識。動物は体格に応じた面積を必要とし、その合計が区画の広さを超えると過密になる。
RSpec.describe '飼育密度と過密' do
  shared    = Zoo::Domain::Shared
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  husbandry = Zoo::Domain::Husbandry
  stocking  = Zoo::Domain::Husbandry::Stocking

  def pen(capacity, temp)
    Zoo::Domain::Husbandry::Enclosure.new(
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
      enclosure = pen(4, 28) # 広さ400m²
      enclosure.admit(build_adult(catalog.lion, name: 'A'))
      enclosure.admit(build_adult(catalog.lion, name: 'B'))

      expect(stocking.overcrowded?(enclosure)).to be(false)
    end

    it '必要面積の合計が区画の広さを超えると過密になること' do
      enclosure = pen(4, 25) # 広さ400m²
      enclosure.admit(build_adult(catalog.african_elephant)) # 1頭で1250m²必要

      expect(stocking.overcrowded?(enclosure)).to be(true)
    end
  end
end
