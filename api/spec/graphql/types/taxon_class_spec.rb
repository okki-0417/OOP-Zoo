# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::TaxonClass do
  it 'code・label は哺乳類で "mammal"・"哺乳類" を返すこと' do
    expect(run_graphql_field('TaxonClass.code', TaxonClass.mammal)).to eq('mammal')
    expect(run_graphql_field('TaxonClass.label', TaxonClass.mammal)).to eq('哺乳類')
  end
end
