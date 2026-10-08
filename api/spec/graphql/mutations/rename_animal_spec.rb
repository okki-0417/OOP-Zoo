# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::RenameAnimal do
  describe 'renameAnimal(animalId:, newName:)' do
    subject(:response) do
      OopZooSchema.execute(%(mutation { renameAnimal(animalId: "#{lion.id}", newName: "シンバ") { name } })).to_h
    end

    let(:lion) { create(:animal, name: 'レオ') }

    it 'シンバを返すこと' do
      expect(response).to eq('data' => { 'renameAnimal' => { 'name' => 'シンバ' } })
    end

    it 'レオの名前をシンバにして保存すること' do
      response

      expect(lion.reload.name).to eq('シンバ')
    end
  end
end
