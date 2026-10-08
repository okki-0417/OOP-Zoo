# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AcquireAnimal do
  describe 'acquireAnimal(speciesCode:, name:, sex:)' do
    subject(:response) do
      OopZooSchema.execute(%(mutation { acquireAnimal(speciesCode: "#{species_code}", name: "レオ", sex: MALE) { name } })).to_h
    end

    let(:species_code) { 'lion' }

    context 'speciesCode が "lion" のとき' do
      it 'レオを返すこと' do
        expect(response).to eq('data' => { 'acquireAnimal' => { 'name' => 'レオ' } })
      end

      it 'ライオンのレオを保存すること' do
        response

        expect(Animal.sole).to have_attributes(name: 'レオ', species: SpeciesCatalog.lion)
      end
    end

    context 'speciesCode が未知の "dragon" のとき' do
      let(:species_code) { 'dragon' }

      it "extensions.code を 'SpeciesNotFound' にし、動物を保存しないこと" do
        expect(response['errors'].first['extensions']).to eq('code' => 'SpeciesNotFound')
        expect(Animal.count).to eq(0)
      end
    end
  end
end
