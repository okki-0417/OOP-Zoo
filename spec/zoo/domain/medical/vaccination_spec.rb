# frozen_string_literal: true

require 'spec_helper'

# 予防接種の技術契約。意味は spec/knowledge/「予防接種と免疫」を参照。
RSpec.describe 'Animal#vaccinate' do
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  illnesses = Zoo::Domain::Medical::IllnessCatalog
  errors    = Zoo::Domain::Errors

  it '感染性の病気を接種すると免疫一覧に加わること' do
    lion = build_adult(catalog.lion)
    lion.vaccinate(illnesses.cold)
    expect(lion.immunities).to include(illnesses.cold)
  end

  it '二重接種しても免疫は重複しないこと' do
    lion = build_adult(catalog.lion)
    lion.vaccinate(illnesses.cold)
    lion.vaccinate(illnesses.cold)
    expect(lion.immunities.count { |i| i == illnesses.cold }).to eq(1)
  end

  it '感染性でない病気は接種できないこと(VaccineUnavailable)' do
    lion = build_adult(catalog.lion)
    expect { lion.vaccinate(illnesses.fracture) }.to raise_error(errors::VaccineUnavailable)
  end

  it '死んだ個体には接種できないこと(DeadAnimal)' do
    lion = build_adult(catalog.lion)
    lion.die
    expect { lion.vaccinate(illnesses.cold) }.to raise_error(errors::DeadAnimal)
  end

  it '接種済みの病気は fall_ill しても発病しないこと' do
    lion = build_adult(catalog.lion)
    lion.vaccinate(illnesses.cold)
    lion.fall_ill(illnesses.cold)
    expect(lion).not_to be_sick
  end
end
