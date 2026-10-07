# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Species do
  let(:lion) { SpeciesCatalog.lion }

  describe 'code' do
    it 'ライオンのカタログのキー "lion" を返すこと' do
      expect(run_graphql_field('Species.code', lion)).to eq('lion')
    end
  end

  describe 'diet' do
    it '"肉食" を返すこと' do
      expect(run_graphql_field('Species.diet', lion)).to eq('肉食')
    end
  end

  describe 'conservationCode' do
    it '"VU" を返すこと' do
      expect(run_graphql_field('Species.conservationCode', lion)).to eq('VU')
    end
  end

  describe 'conservationLabel' do
    it '"危急" を返すこと' do
      expect(run_graphql_field('Species.conservationLabel', lion)).to eq('危急')
    end
  end

  describe 'threatened' do
    it 'true を返すこと' do
      expect(run_graphql_field('Species.threatened', lion)).to be(true)
    end
  end

  describe 'charisma' do
    it '90 を返すこと' do
      expect(run_graphql_field('Species.charisma', lion)).to eq(90)
    end
  end
end
