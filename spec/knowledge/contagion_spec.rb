# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '病気の感染と免疫' do
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  illnesses = Zoo::Domain::Medical::IllnessCatalog
  contagion = Zoo::Domain::Medical::Contagion

  def pride(*animals)
    enclosure = Zoo::Domain::Husbandry::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 6
    )
    animals.each { |a| enclosure.admit(a) }
    enclosure
  end

  describe '接触感染' do
    it '感染性の病気を持つ個体がいると、同じエリアの健康な個体に広がること' do
      carrier = build_adult(catalog.lion, name: '感染源')
      healthy = build_adult(catalog.lion, name: '健康')
      carrier.fall_ill(illnesses.cold)
      enclosure = pride(carrier, healthy)

      contagion.spread(enclosure)

      expect(healthy).to be_sick
    end

    it '感染性でない病気(骨折)は広がらないこと' do
      injured = build_adult(catalog.lion, name: '骨折')
      healthy = build_adult(catalog.lion, name: '健康')
      injured.fall_ill(illnesses.fracture)
      enclosure = pride(injured, healthy)

      contagion.spread(enclosure)

      expect(healthy).not_to be_sick
    end

    it '別のエリアの個体には広がらないこと' do
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)
      faraway = build_adult(catalog.lion, name: '別エリア')
      sick_enclosure = pride(carrier)
      pride(faraway)

      contagion.spread(sick_enclosure)

      expect(faraway).not_to be_sick
    end
  end

  describe '免疫' do
    it '病気から回復すると、その病気に免疫を持つこと' do
      lion = build_adult(catalog.lion)
      lion.fall_ill(illnesses.cold)
      lion.recover

      expect(lion.immune_to?(illnesses.cold)).to be(true)
    end

    it '免疫を持つ病気には接触しても再びかからないこと' do
      recovered = build_adult(catalog.lion, name: '回復済み')
      recovered.fall_ill(illnesses.cold)
      recovered.recover
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)
      enclosure = pride(recovered, carrier)

      contagion.spread(enclosure)

      expect(recovered).not_to be_sick
    end
  end
end
