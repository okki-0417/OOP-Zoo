# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Subscribers::MemorialLog do
  events  = Zoo::Domain::Events
  catalog = Zoo::Domain::SpeciesCatalog

  let(:animal) { build_adult(catalog.lion, name: 'レオ') }

  describe '#handle' do
    it 'AnimalDied を渡すと entries が1件増えること' do
      log = described_class.new

      log.handle(events::AnimalDied.new(animal: animal, cause: :old_age))

      expect(log.entries.size).to eq(1)
    end

    it 'AnimalBorn を渡しても entries は増えないこと(関心外のイベントは無視する)' do
      log = described_class.new

      log.handle(events::AnimalBorn.new(animal: animal, sire_id: 's', dam_id: 'd'))

      expect(log.entries).to be_empty
    end
  end
end
