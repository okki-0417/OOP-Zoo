# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Occupancy do
  it 'full・overcrowded は定員1に1頭で true・false を返すこと' do
    occupancy = Occupancy.new(enclosure: build(:enclosure, capacity: 1), occupants: [build(:animal)])

    expect(run_graphql_field('Occupancy.full', occupancy)).to be(true)
    expect(run_graphql_field('Occupancy.overcrowded', occupancy)).to be(false)
  end
end
