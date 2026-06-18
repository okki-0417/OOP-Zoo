# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::EventDispatcher do
  events    = Zoo::Domain::Events
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  subscribers = Zoo::Infrastructure::Subscribers

  let(:animal) { build_adult(catalog.lion, name: 'レオ') }
  let(:died) { events::AnimalDied.new(animal: animal, cause: :old_age) }

  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:memorial_log) { subscribers::MemorialLog.new }
  let(:dispatcher) { described_class.new(event_store: event_store, subscribers: [memorial_log]) }

  describe '#publish' do
    it '渡したイベントを EventStore に永続化すること' do
      dispatcher.publish([died])

      expect(event_store.all).to eq([died])
    end

    it '渡したイベントを各購読者へ通知すること' do
      dispatcher.publish([died])

      expect(memorial_log.entries.size).to eq(1)
    end

    it '空配列を渡すと永続化も通知も起きないこと' do
      dispatcher.publish([])

      expect(event_store.all).to be_empty
      expect(memorial_log.entries).to be_empty
    end
  end
end
