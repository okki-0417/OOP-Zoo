# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AddEnclosure do
  shared    = Zoo::Domain::Shared
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures]) }
  let(:service) { described_class.new(enclosures: enclosures, unit_of_work: unit_of_work) }

  describe '#call' do
    it 'name/temperature/capacity を渡すと、採番された id で find できるエリアが保存されること' do
      enclosure = service.call(commands::AddEnclosureCommand.new(
                                 name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4
                               ))

      expect(enclosures.find(enclosure.id)).to eq(enclosure)
      expect(enclosure.name).to eq('ライオンの丘')
    end

    it '空の name を渡すと Enclosure の不変条件で ArgumentError が発生すること' do
      command = commands::AddEnclosureCommand.new(
        name: '', temperature: shared::Temperature.celsius(28), capacity: 4
      )

      expect { service.call(command) }.to raise_error(ArgumentError)
    end
  end
end
