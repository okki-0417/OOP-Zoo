# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Zoo::Infrastructure::Sqlite::Database do
  describe '.new' do
    it '後から追加した列(animals.nutrition / enclosures.enrichment / housing_events.closes_housing_id)を持たない既存DBに、既定値付きで列を足すこと' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'old.db')
        legacy = Sequel.sqlite(path)
        legacy.run('CREATE TABLE animals (id TEXT PRIMARY KEY, name TEXT)')
        legacy.run('CREATE TABLE enclosures (id TEXT PRIMARY KEY, name TEXT)')
        legacy.run('CREATE TABLE housing_events (seq INTEGER PRIMARY KEY, id TEXT, animal_id TEXT)')
        legacy.run('CREATE TABLE keepers (id TEXT PRIMARY KEY, name TEXT)')
        legacy.run("INSERT INTO animals (id, name) VALUES ('a1', 'レオ')")
        legacy.disconnect

        database = described_class.new(path)

        expect(database.execute('SELECT nutrition, meals, miscarried FROM animals'))
          .to eq([{ 'nutrition' => 100, 'meals' => '', 'miscarried' => 0 }])
        expect(database.dataset(:enclosures).columns).to include(:enrichment, :climate_controlled)
        expect(database.dataset(:housing_events).columns).to include(:closes_housing_id)
        expect(database.dataset(:keepers).columns).to include(:worked_minutes)
      end
    end

    it '2回開いても列の追加は1回だけで、エラーにならないこと' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'zoo.db')
        described_class.new(path)
        expect { described_class.new(path) }.not_to raise_error
      end
    end
  end
end
