# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Animal#vaccinate' do
  subject(:lion) { build(:animal) }

  context '感染性の風邪を接種したとき' do
    before { lion.vaccinate(IllnessCatalog.cold) }

    it 'immunities に風邪が加わること' do
      expect(lion.immunities).to include(IllnessCatalog.cold)
    end

    it 'もう一度風邪を接種しても、immunities の風邪は 1 つのままであること' do
      lion.vaccinate(IllnessCatalog.cold)

      expect(lion.immunities.count(IllnessCatalog.cold)).to eq(1)
    end

    it '風邪に fall_ill しても発病しないこと' do
      lion.fall_ill(IllnessCatalog.cold)

      expect(lion).not_to be_sick
    end
  end

  context '感染性でない骨折を接種するとき' do
    it 'VaccineUnavailable を投げること' do
      expect { lion.vaccinate(IllnessCatalog.fracture) }.to raise_error(Errors::VaccineUnavailable)
    end
  end

  context '死亡した個体に接種するとき' do
    subject(:lion) { build(:animal).die }

    it 'DeadAnimal を投げること' do
      expect { lion.vaccinate(IllnessCatalog.cold) }.to raise_error(Errors::DeadAnimal)
    end
  end
end
