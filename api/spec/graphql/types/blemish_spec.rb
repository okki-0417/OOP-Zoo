# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Blemish do
  it 'cause・penalty は { cause: :sick, penalty: 40 } から :sick(SICK)・40 を返すこと' do
    blemish = { cause: :sick, penalty: 40 }

    expect(Types::BlemishCause.coerce_isolated_result(run_graphql_field('Blemish.cause', blemish))).to eq('SICK')
    expect(run_graphql_field('Blemish.penalty', blemish)).to eq(40)
  end
end
