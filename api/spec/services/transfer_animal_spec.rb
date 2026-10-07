# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::TransferAnimal do
  let!(:from) { create_enclosure(name: '丘A', capacity: 4) }
  let!(:to) { create_enclosure(name: '丘B', capacity: 4) }
  let!(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ').move_to(from).tap(&:save!) }

  def transfer(enclosure_id)
    command = Services::Commands::TransferAnimalCommand.new(animal_id: lion.id, enclosure_id:)
    described_class.new(command:).call
  end

  describe '#call' do
    it '個体を別エリアへ移すと、移送先に収容され移送元から外れること' do
      transfer(to.id)

      expect(to.animals.reload).to include(lion)
      expect(from.animals.reload).not_to include(lion)
    end

    it '移送に成功すると result.value がライオンで、収容先が丘Bになること' do
      result = transfer(to.id)

      expect(result.value).to eq(lion)
      expect(lion.reload.enclosure.name).to eq('丘B')
    end

    it '存在しない enclosure_id=\'missing\' を渡すと result.error が EnclosureNotFound になること' do
      expect(transfer('missing').error).to be_a(Services::Errors::EnclosureNotFound)
    end

    it '移送先が満員だと result.error が定員を理由とする HousingNotAllowed になり、個体は移送元に残ること' do
      full = create_enclosure(name: '満室', capacity: 1)
      build_adult(SpeciesCatalog.lion, name: '先住').move_to(full).save!

      result = transfer(full.id)

      expect(result.error).to be_a(Errors::HousingNotAllowed)
      expect(result.error.message).to match(/定員/)
      expect(lion.reload.enclosure).to eq(from)
    end
  end
end
