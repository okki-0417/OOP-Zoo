# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::RenameAnimal do
  describe 'renameAnimal(animalId:, newName:)' do
    subject(:response) do
      OopZooSchema.execute(%(mutation { renameAnimal(animalId: "#{lion.id}", newName: "シンバ") { name } }), context: { current_zoo: zoo }).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:lion) { create(:animal, zoo:, name: 'レオ') }

    it 'シンバを返すこと' do
      expect(response).to eq('data' => { 'renameAnimal' => { 'name' => 'シンバ' } })
    end

    it 'レオの名前をシンバにして保存すること' do
      response

      expect(lion.reload.name).to eq('シンバ')
    end
  end
end
