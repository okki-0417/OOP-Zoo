# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '病気の感染と免疫' do
  def pen
    build(:enclosure, name: 'ライオンの丘', capacity: 6)
  end

  def occupancy(enclosure, occupants)
    Occupancy.new(enclosure: enclosure, occupants: occupants)
  end

  describe '接触感染' do
    it '感染性の病気を持つ個体がいると、同じエリアの健康な個体に広がること' do
      carrier = build(:animal, name: '感染源')
      healthy = build(:animal, name: '健康')
      carrier.fall_ill(IllnessCatalog.cold)

      Contagion.new(pen, occupancy(pen, [carrier, healthy])).spread

      expect(healthy).to be_sick
    end

    it '感染性でない病気(骨折)は広がらないこと' do
      injured = build(:animal, name: '骨折')
      healthy = build(:animal, name: '健康')
      injured.fall_ill(IllnessCatalog.fracture)

      Contagion.new(pen, occupancy(pen, [injured, healthy])).spread

      expect(healthy).not_to be_sick
    end

    it '別のエリアの個体には広がらないこと' do
      carrier = build(:animal, name: '感染源')
      carrier.fall_ill(IllnessCatalog.cold)
      faraway = build(:animal, name: '別エリア')

      Contagion.new(pen, occupancy(pen, [carrier])).spread

      expect(faraway).not_to be_sick
    end
  end

  describe '免疫' do
    it '病気から回復すると、その病気に免疫を持つこと' do
      lion = build(:animal)
      lion.fall_ill(IllnessCatalog.cold)
      lion.recover

      expect(lion.immune_to?(IllnessCatalog.cold)).to be(true)
    end

    it '免疫を持つ病気には接触しても再びかからないこと' do
      recovered = build(:animal, name: '回復済み')
      recovered.fall_ill(IllnessCatalog.cold)
      recovered.recover
      carrier = build(:animal, name: '感染源')
      carrier.fall_ill(IllnessCatalog.cold)

      Contagion.new(pen, occupancy(pen, [recovered, carrier])).spread

      expect(recovered).not_to be_sick
    end
  end
end
