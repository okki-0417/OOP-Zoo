# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Examination do
  it 'animal・diagnosis は { animal: レオ, diagnosis: :healthy } からレオ・HEALTHY を返すこと' do
    leo = build(:animal, name: 'レオ')
    examination = { animal: leo, diagnosis: :healthy }

    expect(run_graphql_field('Examination.animal', examination)).to eq(leo)
    expect(Types::Diagnosis.coerce_isolated_result(run_graphql_field('Examination.diagnosis', examination)))
      .to eq('HEALTHY')
  end
end
