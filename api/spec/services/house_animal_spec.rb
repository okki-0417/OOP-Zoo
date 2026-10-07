# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::HouseAnimal do
  let!(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ').tap(&:save!) }
  let!(:enclosure) { create_enclosure(name: 'ライオンの丘', capacity: 2) }

  def call_with(enclosure_id:, animal_id:)
    command = Services::Commands::HouseAnimalCommand.new(enclosure_id:, animal_id:)
    described_class.new(command:).call
  end

  describe '#call' do
    it 'エリアと動物の id を渡すと、保存されたその動物の enclosure がそのエリアになること' do
      call_with(enclosure_id: enclosure.id, animal_id: lion.id)

      expect(lion.reload.enclosure).to eq(enclosure)
    end

    it '収容に成功すると result.value がそのエリアで、住人がレオ1頭になること' do
      result = call_with(enclosure_id: enclosure.id, animal_id: lion.id)

      expect(result.value).to eq(enclosure)
      expect(enclosure.animals.reload.map(&:name)).to eq(['レオ'])
    end

    it '存在しない enclosure_id=\'missing\' を渡すと result.error が Application::Errors::EnclosureNotFound になること' do
      result = call_with(enclosure_id: 'missing', animal_id: lion.id)

      expect(result.error).to be_a(Services::Errors::EnclosureNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が Application::Errors::AnimalNotFound になること' do
      result = call_with(enclosure_id: enclosure.id, animal_id: 'missing')

      expect(result.error).to be_a(Services::Errors::AnimalNotFound)
    end

    it '定員1の満員エリアに収容しようとすると result.error が定員を理由とする Errors::HousingNotAllowed になり、未収容のままであること' do
      full = create_enclosure(name: '小屋', capacity: 1)
      build_adult(SpeciesCatalog.lion, name: '先住').move_to(full).save!

      result = call_with(enclosure_id: full.id, animal_id: lion.id)

      expect(result.error).to be_a(Errors::HousingNotAllowed)
      expect(result.error.message).to match(/定員/)
      expect(lion.reload.enclosure).to be_nil
    end
  end
end
