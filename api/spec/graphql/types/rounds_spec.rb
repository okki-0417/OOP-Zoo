# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Rounds do
  let(:keeper) { build(:keeper, name: '田中') }
  let(:rounds) { { keeper:, reports: [] } }

  describe 'keeper' do
    it '{ keeper: 田中 } から田中を返すこと' do
      expect(run_graphql_field('Rounds.keeper', rounds)).to eq(keeper)
    end
  end

  describe 'reports' do
    it '{ reports: [] } から [] を返すこと' do
      expect(run_graphql_field('Rounds.reports', rounds)).to eq([])
    end
  end
end
