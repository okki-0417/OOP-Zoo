# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::RenameAnimal do
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:lion) { build_adult(catalog.lion, name: 'レオ').tap(&:save!) }

  def rename(animal_id, new_name)
    described_class.new(command: Zoo::Application::Commands::RenameAnimalCommand.new(animal_id:, new_name:)).call
  end

  describe '#call' do
    it 'new_name=\'シンバ\' で改名すると保存された名前が変わり、result.value の名前が \'シンバ\' になること' do
      animal = rename(lion.id, 'シンバ').value

      expect(lion.reload.name).to eq('シンバ')
      expect(animal.name).to eq('シンバ')
    end

    it '存在しない animal_id=\'missing\' で result.error が Application::Errors::AnimalNotFound になること' do
      expect(rename('missing', 'X').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
