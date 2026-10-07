# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::RoundReport do
  let(:hill) { build(:enclosure, name: 'ライオンの丘') }
  let(:leo) { build(:animal, name: 'レオ') }
  let(:report) do
    Rounding::Report.new(enclosure: hill, fed: [leo], skipped: [%w[ペン 専門外のため給餌できません]],
                         cleaned: true, enriched: false)
  end

  describe 'skipped' do
    it '[名前, 理由] の組を [{ subject: "ペン", reason: "専門外のため給餌できません" }] にして返すこと' do
      expect(run_graphql_field('RoundReport.skipped', report))
        .to eq([{ subject: 'ペン', reason: '専門外のため給餌できません' }])
    end
  end

  describe 'enclosure' do
    it 'ライオンの丘を返すこと' do
      expect(run_graphql_field('RoundReport.enclosure', report)).to eq(hill)
    end
  end

  describe 'fed' do
    it '[レオ] を返すこと' do
      expect(run_graphql_field('RoundReport.fed', report)).to eq([leo])
    end
  end

  describe 'cleaned' do
    it 'true を返すこと' do
      expect(run_graphql_field('RoundReport.cleaned', report)).to be(true)
    end
  end

  describe 'enriched' do
    it 'false を返すこと' do
      expect(run_graphql_field('RoundReport.enriched', report)).to be(false)
    end
  end
end
