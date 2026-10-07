# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::RenameAnimal do
  let!(:lion) { create(:animal, name: 'レオ') }

  def rename(animal_id, new_name)
    described_class.new(command: Services::Commands::RenameAnimalCommand.new(animal_id:, new_name:)).call
  end

  describe '#call' do
    it 'new_name=\'シンバ\' で改名すると保存された名前が変わり、result.value の名前が \'シンバ\' になること' do
      animal = rename(lion.id, 'シンバ').value

      expect(lion.reload.name).to eq('シンバ')
      expect(animal.name).to eq('シンバ')
    end

    it '存在しない animal_id=\'missing\' で result.error が Application::Errors::AnimalNotFound になること' do
      expect(rename('missing', 'X').error).to be_a(Services::Errors::AnimalNotFound)
    end
  end
end
