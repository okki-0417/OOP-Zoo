# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Occupancy do
  let(:occupancy) { Occupancy.new(enclosure: build(:enclosure, capacity: 1), occupants: [build(:animal)]) }

  context '定員1に1頭いるとき' do
    describe 'full' do
      it 'true を返すこと' do
        expect(run_graphql_field('Occupancy.full', occupancy)).to be(true)
      end
    end

    describe 'overcrowded' do
      it 'false を返すこと' do
        expect(run_graphql_field('Occupancy.overcrowded', occupancy)).to be(false)
      end
    end
  end
end
