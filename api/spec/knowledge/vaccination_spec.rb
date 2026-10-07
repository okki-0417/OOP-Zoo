# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '予防接種と免疫' do
  def pen
    Enclosure.new(
      name: 'ライオンの丘', temperature: Temperature.celsius(28), capacity: 6
    )
  end

  def occupancy(enclosure, occupants)
    build_occupancy(enclosure, occupants)
  end

  describe '感染性の病気へのワクチン' do
    it '接種するとかかる前から免疫を得ること' do
      lion = build_adult(SpeciesCatalog.lion)
      lion.vaccinate(IllnessCatalog.cold)
      expect(lion.immune_to?(IllnessCatalog.cold)).to be(true)
    end

    it '接種済みなら感染源と同居しても発病しないこと' do
      vaccinated = build_adult(SpeciesCatalog.lion, name: '接種済み')
      vaccinated.vaccinate(IllnessCatalog.cold)
      carrier = build_adult(SpeciesCatalog.lion, name: '感染源')
      carrier.fall_ill(IllnessCatalog.cold)

      Contagion.new(pen, occupancy(pen, [vaccinated, carrier])).spread

      expect(vaccinated).not_to be_sick
    end
  end

  describe '感染性でない病気へのワクチン' do
    it '骨折にはワクチンが無く、接種できないこと' do
      lion = build_adult(SpeciesCatalog.lion)
      expect { lion.vaccinate(IllnessCatalog.fracture) }.to raise_error(Errors::VaccineUnavailable)
    end
  end
end
