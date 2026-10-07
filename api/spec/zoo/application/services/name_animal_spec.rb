# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::NameAnimal do
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:animal) do
    build_adult(catalog.lion, name: 'ライオンの赤ちゃん', sex: Zoo::Domain::Animal::Sex.female).tap(&:save!)
  end

  def call_with(animal_id: animal.id, name: 'ナラ')
    described_class.new(command: Zoo::Application::Commands::NameAnimalCommand.new(animal_id:, name:)).call
  end

  describe '#call' do
    it 'name=\'ナラ\' を渡すと保存された動物の名前が更新され、result.value は nil になること' do
      result = call_with(name: 'ナラ')

      expect(animal.reload.name).to eq('ナラ')
      expect(result.value).to be_nil
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が AnimalNotFound になること' do
      expect(call_with(animal_id: 'missing').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
