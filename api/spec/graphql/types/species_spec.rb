# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Species do
  let(:lion) { SpeciesCatalog.lion }

  it 'code はライオンのカタログのキー "lion" を返すこと' do
    expect(run_graphql_field('Species.code', lion)).to eq('lion')
  end

  it 'diet・conservationCode・conservationLabel・threatened・charisma は "肉食"・"VU"・"危急"・true・90 を返すこと' do
    expect(run_graphql_field('Species.diet', lion)).to eq('肉食')
    expect(run_graphql_field('Species.conservationCode', lion)).to eq('VU')
    expect(run_graphql_field('Species.conservationLabel', lion)).to eq('危急')
    expect(run_graphql_field('Species.threatened', lion)).to be(true)
    expect(run_graphql_field('Species.charisma', lion)).to eq(90)
  end
end
