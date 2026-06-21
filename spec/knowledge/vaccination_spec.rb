# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '予防接種と免疫' do
  catalog   = Zoo::Domain::SpeciesCatalog
  illnesses = Zoo::Domain::IllnessCatalog
  contagion = Zoo::Domain::Contagion
  errors    = Zoo::Domain::Errors

  def pen
    Zoo::Domain::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 6
    )
  end

  describe '感染性の病気へのワクチン' do
    it '接種するとかかる前から免疫を得ること' do
      lion = build_adult(catalog.lion)
      lion.vaccinate(illnesses.cold)
      expect(lion.immune_to?(illnesses.cold)).to be(true)
    end

    it '接種済みなら感染源と同居しても発病しないこと' do
      vaccinated = build_adult(catalog.lion, name: '接種済み')
      vaccinated.vaccinate(illnesses.cold)
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)

      contagion.new(pen, [vaccinated, carrier]).spread

      expect(vaccinated).not_to be_sick
    end
  end

  describe '感染性でない病気へのワクチン' do
    it '骨折にはワクチンが無く、接種できないこと' do
      lion = build_adult(catalog.lion)
      expect { lion.vaccinate(illnesses.fracture) }.to raise_error(errors::VaccineUnavailable)
    end
  end
end
