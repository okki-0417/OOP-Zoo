# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Blemish do
  let(:blemish) { { cause: :sick, penalty: 40 } }

  describe 'cause' do
    it '{ cause: :sick } から :sick(BlemishCause の SICK)を返すこと' do
      expect(Types::BlemishCause.coerce_isolated_result(run_graphql_field('Blemish.cause', blemish))).to eq('SICK')
    end
  end

  describe 'penalty' do
    it '{ penalty: 40 } から 40 を返すこと' do
      expect(run_graphql_field('Blemish.penalty', blemish)).to eq(40)
    end
  end
end
