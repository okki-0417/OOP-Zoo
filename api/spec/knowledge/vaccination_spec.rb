# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '予防接種と免疫' do
  def pen
    build(:enclosure, name: 'ライオンの丘', capacity: 6)
  end

  def occupancy(enclosure, occupants)
    Occupancy.new(enclosure: enclosure, occupants: occupants)
  end

  describe '感染性の病気へのワクチン' do
    it '接種するとかかる前から免疫を得ること' do
      lion = build(:animal)
      lion.vaccinate(IllnessCatalog.cold)
      expect(lion.immune_to?(IllnessCatalog.cold)).to be(true)
    end

    it '接種済みなら感染源と同居しても発病しないこと' do
      vaccinated = build(:animal, name: '接種済み')
      vaccinated.vaccinate(IllnessCatalog.cold)
      carrier = build(:animal, name: '感染源')
      carrier.fall_ill(IllnessCatalog.cold)

      Contagion.new(pen, occupancy(pen, [vaccinated, carrier])).spread

      expect(vaccinated).not_to be_sick
    end
  end

  describe '感染性でない病気へのワクチン' do
    it '骨折にはワクチンが無く、接種できないこと' do
      lion = build(:animal)
      expect { lion.vaccinate(IllnessCatalog.fracture) }.to raise_error(Errors::VaccineUnavailable)
    end
  end
end
