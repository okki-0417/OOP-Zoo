# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Rounds do
  it 'keeper・reports は { keeper: 田中, reports: [] } から田中・[] を返すこと' do
    keeper = build(:keeper, name: '田中')
    rounds = { keeper:, reports: [] }

    expect(run_graphql_field('Rounds.keeper', rounds)).to eq(keeper)
    expect(run_graphql_field('Rounds.reports', rounds)).to eq([])
  end
end
