# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::NameAnimal do
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:animal) { build_adult(catalog.lion, name: 'ライオンの赤ちゃん', sex: Zoo::Domain::Animal::Sex.female) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([animal]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }

  def call_with(animal_id: animal.id, name: 'ナラ')
    command = Zoo::Application::Commands::NameAnimalCommand.new(animal_id:, name:).bind(animals:, unit_of_work:)
    described_class.new(command: command).call
  end

  describe '#call' do
    it 'name=\'ナラ\' を渡すと動物の名前が更新され、result.value は nil になること' do
      result = call_with(name: 'ナラ')

      expect(animals.find(animal.id).name.to_s).to eq('ナラ')
      expect(result.value).to be_nil
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が AnimalNotFound になること' do
      expect(call_with(animal_id: 'missing').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
