# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Sqlite::HousingRepository do
  let(:database) { Zoo::Infrastructure::Sqlite::Database.new }
  let(:animals) { Zoo::Infrastructure::Sqlite::AnimalRepository.new(database) }
  let(:enclosures) { Zoo::Infrastructure::Sqlite::EnclosureRepository.new(database) }
  let(:repository) { described_class.new(database, animals, enclosures) }

  def persist_animals(*list)
    list.each { |animal| animals.save(animal) }
  end

  def persist_enclosures(*list)
    list.each { |enclosure| enclosures.save(enclosure) }
  end

  it_behaves_like 'a housing repository'
end
