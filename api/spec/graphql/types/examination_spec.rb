# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Examination do
  let(:leo) { build(:animal, name: 'レオ') }
  let(:examination) { { animal: leo, diagnosis: :healthy } }

  describe 'animal' do
    it '{ animal: レオ } からレオを返すこと' do
      expect(run_graphql_field('Examination.animal', examination)).to eq(leo)
    end
  end

  describe 'diagnosis' do
    it '{ diagnosis: :healthy } から HEALTHY を返すこと' do
      expect(Types::Diagnosis.coerce_isolated_result(run_graphql_field('Examination.diagnosis', examination)))
        .to eq('HEALTHY')
    end
  end
end
