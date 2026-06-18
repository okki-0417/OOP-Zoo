# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::DeceasedList do
  catalog   = Zoo::Domain::SpeciesCatalog
  events    = Zoo::Domain::Events
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:query) { described_class.new(event_store: event_store) }

  describe '#call' do
    it 'AnimalDied を死因つきの慰霊記録として返すこと' do
      event_store.append(events::AnimalDied.new(animal: lion, cause: :old_age))

      record = query.call.first

      expect(record.name).to eq('レオ')
      expect(record.species).to eq('ライオン')
      expect(record.cause).to eq(:old_age)
    end

    it '死亡が無ければ空配列を返すこと' do
      expect(query.call).to eq([])
    end
  end
end
