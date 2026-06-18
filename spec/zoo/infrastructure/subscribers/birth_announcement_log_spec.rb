# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Subscribers::BirthAnnouncementLog do
  events  = Zoo::Domain::Events
  catalog = Zoo::Domain::SpeciesCatalog

  let(:animal) { build_adult(catalog.lion, name: 'シンバ') }

  describe '#handle' do
    it 'AnimalBorn を渡すと announcements が1件増えること' do
      log = described_class.new

      log.handle(events::AnimalBorn.new(animal: animal, sire_id: 's', dam_id: 'd'))

      expect(log.announcements.size).to eq(1)
    end

    it 'AnimalDied を渡しても announcements は増えないこと(関心外のイベントは無視する)' do
      log = described_class.new

      log.handle(events::AnimalDied.new(animal: animal, cause: :old_age))

      expect(log.announcements).to be_empty
    end
  end
end
