# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Container on SQLite (end-to-end)' do
  commands    = Zoo::Application::Commands
  passthrough = Zoo::Presentation::Renderers::Passthrough

  it 'acquire→build-enclosure→house→operate の結果が別インスタンスでも永続化されること' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'zoo.db')

      container = Zoo::Composition::Container.new(database: path)
      enclosure = container.add_enclosure(
        commands::AddEnclosureCommand.new(name: 'サバンナ', celsius: 30, capacity: 6), renderer: passthrough
      ).value[:enclosure]
      zebra = container.acquire_animal(
        commands::AcquireAnimalCommand.new(species_code: 'grevys_zebra', name: 'シマオ', sex: 'male'), renderer: passthrough
      ).value[:animal]
      container.house_animal(
        commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: zebra.id), renderer: passthrough
      )
      container.operate_day(commands::OperateDayCommand.new, renderer: passthrough)

      reopened = Zoo::Composition::Container.new(database: path)

      expect(reopened.population(commands::PopulationCommand.new, renderer: passthrough).value).to eq(1)
      expect(reopened.animal_list(commands::AnimalListCommand.new, renderer: passthrough).value.map(&:name))
        .to include('シマオ')
      expect(reopened.revenue(commands::RevenueCommand.new, renderer: passthrough).value.yen).to be >= 0
    end
  end
end
