# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::SkippedWork do
  let(:skipped) { { subject: 'ライオンの丘', reason: '勤務時間が足りず清掃できません' } }

  describe 'subject' do
    it '"ライオンの丘" を返すこと' do
      expect(run_graphql_field('SkippedWork.subject', skipped)).to eq('ライオンの丘')
    end
  end

  describe 'reason' do
    it '"勤務時間が足りず清掃できません" を返すこと' do
      expect(run_graphql_field('SkippedWork.reason', skipped)).to eq('勤務時間が足りず清掃できません')
    end
  end
end
