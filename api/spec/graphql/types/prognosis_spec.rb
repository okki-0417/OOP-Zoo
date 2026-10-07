# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Prognosis do
  let(:lion) { build(:animal) }
  let(:hill) { build(:enclosure) }
  let(:prognosis) do
    Prognosis.new(animal: lion, enclosure: hill, occupancy: Occupancy.new(enclosure: hill, occupants: [lion]),
                  season: Season.spring)
  end

  context '丘で健康なライオンを見立てるとき' do
    describe 'outlook' do
      it ':good(Outlook の GOOD)を返すこと' do
        expect(Types::Outlook.coerce_isolated_result(run_graphql_field('Prognosis.outlook', prognosis))).to eq('GOOD')
      end
    end

    describe 'daysToDeath' do
      it 'nil を返すこと' do
        expect(run_graphql_field('Prognosis.daysToDeath', prognosis)).to be_nil
      end
    end

    describe 'causeOfDeath' do
      it 'nil を返すこと' do
        expect(run_graphql_field('Prognosis.causeOfDeath', prognosis)).to be_nil
      end
    end
  end
end
