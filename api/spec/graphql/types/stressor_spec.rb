# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Stressor do
  it 'cause・amount は { cause: :maternal_separation, amount: 20 } から MATERNAL_SEPARATION・20 を返すこと' do
    stressor = { cause: :maternal_separation, amount: 20 }

    expect(Types::StressorCause.coerce_isolated_result(run_graphql_field('Stressor.cause', stressor)))
      .to eq('MATERNAL_SEPARATION')
    expect(run_graphql_field('Stressor.amount', stressor)).to eq(20)
  end
end
