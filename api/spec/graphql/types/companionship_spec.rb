# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Companionship do
  it 'lonely・separatedDependent・subordinateMale は1頭で暮らす成体のオスで true・false・false を返すこと' do
    lion = build(:animal)
    hill = build(:enclosure)
    companionship = Companionship.new(enclosure: hill, occupancy: Occupancy.new(enclosure: hill, occupants: [lion]),
                                      member: lion)

    expect(run_graphql_field('Companionship.lonely', companionship)).to be(true)
    expect(run_graphql_field('Companionship.separatedDependent', companionship)).to be(false)
    expect(run_graphql_field('Companionship.subordinateMale', companionship)).to be(false)
  end
end
