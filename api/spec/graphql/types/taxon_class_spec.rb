# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::TaxonClass do
  describe 'code' do
    it '哺乳類で "mammal" を返すこと' do
      expect(run_graphql_field('TaxonClass.code', TaxonClass.mammal)).to eq('mammal')
    end
  end

  describe 'label' do
    it '哺乳類で "哺乳類" を返すこと' do
      expect(run_graphql_field('TaxonClass.label', TaxonClass.mammal)).to eq('哺乳類')
    end
  end
end
