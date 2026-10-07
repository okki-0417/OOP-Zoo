# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Animal#vaccinate' do
  it '感染性の病気を接種すると免疫一覧に加わること' do
    lion = build(:animal)
    lion.vaccinate(IllnessCatalog.cold)
    expect(lion.immunities).to include(IllnessCatalog.cold)
  end

  it '二重接種しても免疫は重複しないこと' do
    lion = build(:animal)
    lion.vaccinate(IllnessCatalog.cold)
    lion.vaccinate(IllnessCatalog.cold)
    expect(lion.immunities.count { |i| i == IllnessCatalog.cold }).to eq(1)
  end

  it '感染性でない病気は接種できないこと(VaccineUnavailable)' do
    lion = build(:animal)
    expect { lion.vaccinate(IllnessCatalog.fracture) }.to raise_error(Errors::VaccineUnavailable)
  end

  it '死んだ個体には接種できないこと(DeadAnimal)' do
    lion = build(:animal)
    lion.die
    expect { lion.vaccinate(IllnessCatalog.cold) }.to raise_error(Errors::DeadAnimal)
  end

  it '接種済みの病気は fall_ill しても発病しないこと' do
    lion = build(:animal)
    lion.vaccinate(IllnessCatalog.cold)
    lion.fall_ill(IllnessCatalog.cold)
    expect(lion).not_to be_sick
  end
end
