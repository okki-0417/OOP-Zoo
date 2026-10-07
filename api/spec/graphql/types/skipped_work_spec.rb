# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::SkippedWork do
  it 'subject・reason は { subject: "ライオンの丘", reason: "勤務時間が足りず清掃できません" } の値を返すこと' do
    skipped = { subject: 'ライオンの丘', reason: '勤務時間が足りず清掃できません' }

    expect(run_graphql_field('SkippedWork.subject', skipped)).to eq('ライオンの丘')
    expect(run_graphql_field('SkippedWork.reason', skipped)).to eq('勤務時間が足りず清掃できません')
  end
end
