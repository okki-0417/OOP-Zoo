# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BaseMutation do
  describe '#resolve_with_support' do
    let(:zoo) { create(:zoo) }

    context 'レコードが見つからず RecordNotFound が上がったとき' do
      subject(:response) { OopZooSchema.execute('mutation { releaseAnimal(animalId: "0") { name } }', context: { current_zoo: zoo }).to_h }

      it "data を null にし、errors[0] を message '動物 0 は存在しません'・extensions.code 'AnimalNotFound' にすること" do
        expect(response['data']).to be_nil
        expect(response['errors'].first).to include(
          'message' => '動物 0 は存在しません', 'extensions' => { 'code' => 'AnimalNotFound' }
        )
      end
    end

    context 'ほかの動物園の動物を指定したとき' do
      subject(:response) do
        OopZooSchema.execute(%(mutation { releaseAnimal(animalId: "#{stranger.id}") { name } }), context: { current_zoo: zoo }).to_h
      end

      let(:stranger) { create(:animal, enclosure: create(:enclosure)) }

      it "extensions.code を 'AnimalNotFound' にし、その動物をエリアから出さないこと" do
        expect(response['errors'].first['extensions']).to eq('code' => 'AnimalNotFound')
        expect(stranger.reload.enclosure).not_to be_nil
      end
    end

    context 'ドメインのルール違反(定員1の満員エリアへの収容)で DomainError が上がったとき' do
      subject(:response) do
        OopZooSchema.execute(
          %(mutation { houseAnimal(enclosureId: "#{full.id}", animalId: "#{lion.id}") { name } }),
          context: { current_zoo: zoo }
        ).to_h
      end

      let(:full) { create(:enclosure, zoo:, capacity: 1) }
      let(:lion) { create(:animal, zoo:) }

      before { create(:animal, zoo:, enclosure: full) }

      it "extensions.code を 'HousingNotAllowed' にし、収容を保存しないこと" do
        expect(response['errors'].first['extensions']).to eq('code' => 'HousingNotAllowed')
        expect(lion.reload.enclosure).to be_nil
      end
    end

    context 'バリデーション違反(addEnclosure の capacity: 0)で RecordInvalid が上がったとき' do
      subject(:response) do
        OopZooSchema.execute('mutation { addEnclosure(name: "丘", celsius: 28, capacity: 0) { name } }', context: { current_zoo: zoo }).to_h
      end

      it "extensions.code を 'RecordInvalid' にし、建設の記録を残さないこと" do
        expect(response['errors'].first['extensions']).to eq('code' => 'RecordInvalid')
        expect(zoo.constructings.reload).to be_empty
      end
    end
  end
end
