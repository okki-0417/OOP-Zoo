# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Companionship do
  let(:lion) { build(:animal) }
  let(:hill) { build(:enclosure) }
  let(:companionship) do
    Companionship.new(enclosure: hill, occupancy: Occupancy.new(enclosure: hill, occupants: [lion]), member: lion)
  end

  context '成体のオスが1頭で暮らしているとき' do
    describe 'lonely' do
      it 'true を返すこと' do
        expect(run_graphql_field('Companionship.lonely', companionship)).to be(true)
      end
    end

    describe 'separatedDependent' do
      it 'false を返すこと' do
        expect(run_graphql_field('Companionship.separatedDependent', companionship)).to be(false)
      end
    end

    describe 'subordinateMale' do
      it 'false を返すこと' do
        expect(run_graphql_field('Companionship.subordinateMale', companionship)).to be(false)
      end
    end
  end
end
