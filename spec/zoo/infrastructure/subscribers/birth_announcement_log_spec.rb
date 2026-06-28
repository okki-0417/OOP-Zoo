# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Subscribers::BirthAnnouncementLog do
  domain  = Zoo::Domain
  catalog = Zoo::Domain::SpeciesCatalog

  let(:animal) { build_adult(catalog.lion, name: 'シンバ') }

  def build_birth(offspring)
    Zoo::Domain::Birth.reconstitute(
      id: Zoo::Domain::Shared::Identifier.new,
      sire: offspring, dam: offspring, offspring: offspring,
      occurred_on: 0, season: Zoo::Domain::Season.spring
    )
  end

  describe '#handle' do
    it 'Birth を渡すと announcements が1件増えること' do
      log = described_class.new

      log.handle(build_birth(animal))

      expect(log.announcements.size).to eq(1)
    end

    it 'AnimalDied を渡しても announcements は増えないこと(関心外のイベントは無視する)' do
      log = described_class.new

      log.handle(domain::Events::AnimalDied.new(animal: animal, cause: :old_age))

      expect(log.announcements).to be_empty
    end
  end
end
