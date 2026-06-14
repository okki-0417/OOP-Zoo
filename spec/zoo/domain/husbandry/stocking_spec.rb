# frozen_string_literal: true

require 'spec_helper'

# Stocking の計算上の保証。密度の意味は spec/knowledge/「飼育密度と過密」を参照。
RSpec.describe Zoo::Domain::Husbandry::Stocking do
  shared  = Zoo::Domain::Shared
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog

  def pen(capacity, temp)
    Zoo::Domain::Husbandry::Enclosure.new(
      name: '区画', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: capacity
    )
  end

  describe '.required_area' do
    it '収容個体の必要面積を合計すること' do
      enclosure = pen(4, 28)
      enclosure.admit(build_adult(catalog.grevys_zebra, name: 'z1')) # 400kg → 100m²
      enclosure.admit(build_adult(catalog.grevys_zebra, name: 'z2'))

      expect(described_class.required_area(enclosure)).to eq(200.0)
    end
  end

  describe '.overcrowded?' do
    it '空のエリアは過密でないこと' do
      expect(described_class.overcrowded?(pen(2, 28))).to be(false)
    end

    it '広さに収まれば過密でないこと' do
      enclosure = pen(4, 28)
      enclosure.admit(build_adult(catalog.grevys_zebra))
      expect(described_class.overcrowded?(enclosure)).to be(false)
    end

    it '必要面積が広さを超えると過密であること' do
      enclosure = pen(1, 25) # 広さ100m²
      enclosure.admit(build_adult(catalog.reticulated_giraffe)) # 1200kg → 300m²
      expect(described_class.overcrowded?(enclosure)).to be(true)
    end
  end
end
