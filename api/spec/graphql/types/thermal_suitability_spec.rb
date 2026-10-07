# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::ThermalSuitability do
  it 'habitable・comfortable はライオンを28℃に置くと true・true を返すこと' do
    suitability = ThermalSuitability.new(build(:animal), Temperature.celsius(28))

    expect(run_graphql_field('ThermalSuitability.habitable', suitability)).to be(true)
    expect(run_graphql_field('ThermalSuitability.comfortable', suitability)).to be(true)
  end
end
