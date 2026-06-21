# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Sqlite::EnclosureRepository do
  sqlite = Zoo::Infrastructure::Sqlite

  let(:database) { sqlite::Database.new }
  let(:repository) { described_class.new(database) }

  it_behaves_like 'an enclosure repository'
end
