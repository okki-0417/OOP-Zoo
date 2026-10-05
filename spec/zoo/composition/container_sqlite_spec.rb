# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Container on SQLite (end-to-end)' do
  commands = Zoo::Application::Commands

  it 'acquire→build-enclosure→house→operate の結果が別インスタンスでも永続化されること' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'zoo.db')

      container = Zoo::Composition::Container.new(database: path)
      enclosure = container.add_enclosure(
        commands::AddEnclosureCommand.new(name: 'サバンナ', celsius: 30, capacity: 6)
      ).value
      zebra = container.acquire_animal(
        commands::AcquireAnimalCommand.new(species_code: 'grevys_zebra', name: 'シマオ', sex: 'male')
      ).value
      container.house_animal(
        commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: zebra.id)
      )
      container.operate_day(commands::OperateDayCommand.new)

      reopened = Zoo::Composition::Container.new(database: path)

      expect(reopened.housings.all_occupants.size).to eq(1)
      expect(reopened.animals.all.map(&:name))
        .to include('シマオ')
      expect(reopened.zoo.load.revenue.yen).to be >= 0
    end
  end
end
