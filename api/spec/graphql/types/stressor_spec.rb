# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Stressor do
  let(:stressor) { { cause: :maternal_separation, amount: 20 } }

  describe 'cause' do
    it '{ cause: :maternal_separation } から MATERNAL_SEPARATION を返すこと' do
      expect(Types::StressorCause.coerce_isolated_result(run_graphql_field('Stressor.cause', stressor)))
        .to eq('MATERNAL_SEPARATION')
    end
  end

  describe 'amount' do
    it '{ amount: 20 } から 20 を返すこと' do
      expect(run_graphql_field('Stressor.amount', stressor)).to eq(20)
    end
  end
end
