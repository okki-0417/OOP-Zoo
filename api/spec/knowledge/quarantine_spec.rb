# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '検疫' do
  catalog    = Zoo::Domain::SpeciesCatalog
  illnesses  = Zoo::Domain::IllnessCatalog
  quarantine = Zoo::Domain::Quarantine

  describe '隔離期間' do
    it '導入直後はまだ観察期間を終えていないこと' do
      expect(quarantine.begin).not_to be_period_complete
    end

    it '検疫期間(30日)を満たすと観察期間が完了すること' do
      expect(quarantine.begin.observe(30)).to be_period_complete
    end

    it '観察を進めると残り日数が減っていくこと' do
      q = quarantine.begin.observe(10)
      expect(q.days_remaining).to eq(20)
    end
  end

  describe '検疫解除の判断' do
    it '観察期間が完了し健康なら、解除して合流できること' do
      healthy = build_adult(catalog.lion, name: '健康')
      cleared = quarantine.begin.observe(30)
      expect(cleared.safe_to_release?(healthy)).to be(true)
    end

    it '観察期間が完了しても、病気が出ていれば解除できないこと' do
      sick = build_adult(catalog.lion, name: '発症')
      sick.fall_ill(illnesses.cold)
      cleared = quarantine.begin.observe(30)
      expect(cleared.safe_to_release?(sick)).to be(false)
    end

    it '健康でも観察期間が終わっていなければ解除できないこと' do
      healthy = build_adult(catalog.lion, name: '健康')
      partway = quarantine.begin.observe(10)
      expect(partway.safe_to_release?(healthy)).to be(false)
    end
  end
end
