# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Medical::Contagion do
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  illnesses = Zoo::Domain::Medical::IllnessCatalog

  def pride(*animals)
    enclosure = Zoo::Domain::Husbandry::Enclosure.new(
      name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 6
    )
    animals.each { |a| enclosure.admit(a) }
    enclosure
  end

  describe '.spread' do
    it '感染源がいなければ誰も発病せず、空配列を返すこと' do
      enclosure = pride(build_adult(catalog.lion, name: 'A'), build_adult(catalog.lion, name: 'B'))

      expect(described_class.spread(enclosure)).to eq([])
    end

    it '新たに発病した個体だけを返すこと' do
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)
      healthy = build_adult(catalog.lion, name: '健康')
      enclosure = pride(carrier, healthy)

      expect(described_class.spread(enclosure)).to contain_exactly(healthy)
    end
  end
end
