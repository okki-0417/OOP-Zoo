# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Prognosis do
  it 'outlook・daysToDeath・causeOfDeath は丘で健康なライオンで :good(GOOD)・nil・nil を返すこと' do
    lion = build(:animal)
    hill = build(:enclosure)
    prognosis = Prognosis.new(animal: lion, enclosure: hill, occupancy: Occupancy.new(enclosure: hill, occupants: [lion]),
                              season: Season.spring)

    expect(Types::Outlook.coerce_isolated_result(run_graphql_field('Prognosis.outlook', prognosis))).to eq('GOOD')
    expect(run_graphql_field('Prognosis.daysToDeath', prognosis)).to be_nil
    expect(run_graphql_field('Prognosis.causeOfDeath', prognosis)).to be_nil
  end
end
