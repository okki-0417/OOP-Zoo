# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::ThermalSuitability do
  let(:suitability) { ThermalSuitability.new(build(:animal), Temperature.celsius(28)) }

  context 'ライオンを28℃に置くとき' do
    describe 'habitable' do
      it 'true を返すこと' do
        expect(run_graphql_field('ThermalSuitability.habitable', suitability)).to be(true)
      end
    end

    describe 'comfortable' do
      it 'true を返すこと' do
        expect(run_graphql_field('ThermalSuitability.comfortable', suitability)).to be(true)
      end
    end
  end
end
