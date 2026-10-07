# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::RunDaysSummary do
  let(:summary) { { days: 3, total_deaths: 1, deaths_by_cause: { old_age: 1 } } }

  describe 'days' do
    it '{ days: 3 } から 3 を返すこと' do
      expect(run_graphql_field('RunDaysSummary.days', summary)).to eq(3)
    end
  end

  describe 'totalDeaths' do
    it '{ total_deaths: 1 } から 1 を返すこと' do
      expect(run_graphql_field('RunDaysSummary.totalDeaths', summary)).to eq(1)
    end
  end
end
