# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::RunDaysSummary do
  it 'days・totalDeaths は { days: 3, total_deaths: 1 } から 3・1 を返すこと' do
    summary = { days: 3, total_deaths: 1, deaths_by_cause: { old_age: 1 } }

    expect(run_graphql_field('RunDaysSummary.days', summary)).to eq(3)
    expect(run_graphql_field('RunDaysSummary.totalDeaths', summary)).to eq(1)
  end
end
