# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Veterinarian do
  it 'id・name は保存した獣医 "山田" の id と名前を返すこと' do
    vet = create(:veterinarian, name: '山田')

    expect(run_graphql_field('Veterinarian.id', vet)).to eq(vet.id)
    expect(run_graphql_field('Veterinarian.name', vet)).to eq('山田')
  end
end
