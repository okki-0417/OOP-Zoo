# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::ReleaseAnimal do
  describe 'releaseAnimal(animalId:)' do
    subject(:response) { OopZooSchema.execute(%(mutation { releaseAnimal(animalId: "#{lion.id}") { name } })).to_h }

    let(:lion) { create(:animal, name: 'レオ', enclosure: create(:enclosure)) }

    it 'レオを返すこと' do
      expect(response).to eq('data' => { 'releaseAnimal' => { 'name' => 'レオ' } })
    end

    it 'レオをどのエリアにもいない状態にすること' do
      response

      expect(lion.reload.enclosure).to be_nil
    end
  end
end
