# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Sqlite::AssignmentRepository do
  let(:database) { Zoo::Infrastructure::Sqlite::Database.new }
  let(:keepers) { Zoo::Infrastructure::Sqlite::KeeperRepository.new(database) }
  let(:enclosures) { Zoo::Infrastructure::Sqlite::EnclosureRepository.new(database) }
  let(:repository) { described_class.new(database, keepers, enclosures) }

  def persist_keepers(*list)
    list.each { |keeper| keepers.save(keeper) }
  end

  def persist_enclosures(*list)
    list.each { |enclosure| enclosures.save(enclosure) }
  end

  it_behaves_like 'an assignment repository'
end
