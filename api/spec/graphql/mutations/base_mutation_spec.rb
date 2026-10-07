# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::BaseMutation do
  describe '移行中のサービスの Result の変換' do
    it 'サービスが success(value: レオ) を返すと、data.renameAnimal にその動物の name "レオ" が出ること' do
      stub_service(:rename_animal, Services::Result.success(:rename_animal, build(:animal, name: 'レオ')))

      response = OopZooSchema.execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }').to_h

      expect(response).to eq('data' => { 'renameAnimal' => { 'name' => 'レオ' } })
    end

    it "サービスが failure(AnimalNotFound '動物 a1 は存在しません') を返すと、data が null で errors[0] に message と extensions.code 'AnimalNotFound' が出ること" do
      error = Services::Errors::AnimalNotFound.new('動物 a1 は存在しません')
      stub_service(:rename_animal, Services::Result.failure(:rename_animal, error))

      response = OopZooSchema.execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }').to_h

      expect(response['data']).to be_nil
      expect(response['errors'].first).to include(
        'message' => '動物 a1 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
      )
    end

    it "サービスが failure(DomainError の CapacityExceeded) を返すと、extensions.code が 'CapacityExceeded' になること" do
      stub_service(:rename_animal, Services::Result.failure(:rename_animal, Errors::CapacityExceeded.new('満員です')))

      response = OopZooSchema.execute('mutation { renameAnimal(animalId: "a1", newName: "レオ") { name } }').to_h

      expect(response['errors'].first['extensions']).to eq('code' => 'CapacityExceeded')
    end
  end

  describe '例外の変換' do
    it "存在しない animalId: \"0\" を渡すと、errors[0] が message '動物 0 は存在しません'・extensions.code 'AnimalNotFound' になること" do
      response = OopZooSchema.execute('mutation { releaseAnimal(animalId: "0") { name } }').to_h

      expect(response['data']).to be_nil
      expect(response['errors'].first).to include(
        'message' => '動物 0 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
      )
    end

    it "ドメインのルール違反(定員1の満員エリアへの収容)は extensions.code 'HousingNotAllowed' になり、収容は保存されないこと" do
      full = create(:enclosure, capacity: 1)
      create(:animal, enclosure: full)
      lion = create(:animal)

      response = OopZooSchema.execute(%(mutation { houseAnimal(enclosureId: "#{full.id}", animalId: "#{lion.id}") { name } })).to_h

      expect(response['errors'].first['extensions']).to eq('code' => 'HousingNotAllowed')
      expect(lion.reload.enclosure).to be_nil
    end
  end
end
