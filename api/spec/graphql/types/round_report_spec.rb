# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::RoundReport do
  let(:hill) { build(:enclosure, name: 'ライオンの丘') }
  let(:leo) { build(:animal, name: 'レオ') }
  let(:report) do
    Rounding::Report.new(enclosure: hill, fed: [leo], skipped: [%w[ペン 専門外のため給餌できません]],
                         cleaned: true, enriched: false)
  end

  it 'skipped は [名前, 理由] の組を [{ subject: "ペン", reason: "専門外のため給餌できません" }] にして返すこと' do
    expect(run_graphql_field('RoundReport.skipped', report))
      .to eq([{ subject: 'ペン', reason: '専門外のため給餌できません' }])
  end

  it 'enclosure・fed・cleaned・enriched はライオンの丘・[レオ]・true・false を返すこと' do
    expect(run_graphql_field('RoundReport.enclosure', report)).to eq(hill)
    expect(run_graphql_field('RoundReport.fed', report)).to eq([leo])
    expect(run_graphql_field('RoundReport.cleaned', report)).to be(true)
    expect(run_graphql_field('RoundReport.enriched', report)).to be(false)
  end
end
