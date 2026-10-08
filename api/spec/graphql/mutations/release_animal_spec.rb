# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ReleaseAnimal do
  describe 'releaseAnimal(animalId:)' do
    subject(:response) { OopZooSchema.execute(%(mutation { releaseAnimal(animalId: "#{lion.id}") { name } }), context: { current_zoo: zoo }).to_h }

    let(:zoo) { create(:zoo) }
    let(:lion) { create(:animal, zoo:, name: 'レオ', enclosure: create(:enclosure, zoo:)) }

    it 'レオを返すこと' do
      expect(response).to eq('data' => { 'releaseAnimal' => { 'name' => 'レオ' } })
    end

    it 'レオをどのエリアにもいない状態にすること' do
      response

      expect(lion.reload.enclosure).to be_nil
    end
  end
end
