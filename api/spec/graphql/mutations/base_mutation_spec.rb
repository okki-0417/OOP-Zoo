# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::BaseMutation do
  describe '#perform' do
    subject(:response) { OopZooSchema.execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }').to_h }

    before { stub_service(:rename_animal, result) }

    context 'サービスが success(value: レオ) を返したとき' do
      let(:result) { Services::Result.success(:rename_animal, build(:animal, name: 'レオ')) }

      it 'data.renameAnimal にその動物の name "レオ" を出すこと' do
        expect(response).to eq('data' => { 'renameAnimal' => { 'name' => 'レオ' } })
      end
    end

    context "サービスが failure(AnimalNotFound '動物 a1 は存在しません') を返したとき" do
      let(:result) do
        Services::Result.failure(:rename_animal, Services::Errors::AnimalNotFound.new('動物 a1 は存在しません'))
      end

      it "data を null にし、errors[0] に message と extensions.code 'AnimalNotFound' を出すこと" do
        expect(response['data']).to be_nil
        expect(response['errors'].first).to include(
          'message' => '動物 a1 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
        )
      end
    end

    context 'サービスが failure(DomainError の CapacityExceeded) を返したとき' do
      let(:result) { Services::Result.failure(:rename_animal, Errors::CapacityExceeded.new('満員です')) }

      it "extensions.code を 'CapacityExceeded' にすること" do
        expect(response['errors'].first['extensions']).to eq('code' => 'CapacityExceeded')
      end
    end
  end

  describe '#resolve_with_support' do
    context 'レコードが見つからず RecordNotFound が上がったとき' do
      subject(:response) { OopZooSchema.execute('mutation { releaseAnimal(animalId: "0") { name } }').to_h }

      it "data を null にし、errors[0] を message '動物 0 は存在しません'・extensions.code 'AnimalNotFound' にすること" do
        expect(response['data']).to be_nil
        expect(response['errors'].first).to include(
          'message' => '動物 0 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
        )
      end
    end

    context 'ドメインのルール違反(定員1の満員エリアへの収容)で DomainError が上がったとき' do
      subject(:response) do
        OopZooSchema.execute(
          %(mutation { houseAnimal(enclosureId: "#{full.id}", animalId: "#{lion.id}") { name } })
        ).to_h
      end

      let(:full) { create(:enclosure, capacity: 1) }
      let(:lion) { create(:animal) }

      before { create(:animal, enclosure: full) }

      it "extensions.code を 'HousingNotAllowed' にし、収容を保存しないこと" do
        expect(response['errors'].first['extensions']).to eq('code' => 'HousingNotAllowed')
        expect(lion.reload.enclosure).to be_nil
      end
    end
  end
end
