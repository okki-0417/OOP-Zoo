# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Veterinarian do
  let(:vet) { create(:veterinarian, name: '山田') }

  describe 'id' do
    it '保存した獣医の id を返すこと' do
      expect(run_graphql_field('Veterinarian.id', vet)).to eq(vet.id)
    end
  end

  describe 'name' do
    it '"山田" を返すこと' do
      expect(run_graphql_field('Veterinarian.name', vet)).to eq('山田')
    end
  end
end
