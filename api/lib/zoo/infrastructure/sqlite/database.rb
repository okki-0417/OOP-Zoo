# frozen_string_literal: true

require 'sequel'

module Zoo
  module Infrastructure
    module Sqlite
      class Database
        ADDED_COLUMNS = {
          animals: {
            nutrition: 'INTEGER NOT NULL DEFAULT 100',
            meals: "TEXT NOT NULL DEFAULT ''",
            pregnancy_sex: 'TEXT',
            gestation_days: 'INTEGER',
            pregnancy_inbreeding: 'REAL',
            miscarried: 'INTEGER NOT NULL DEFAULT 0'
          },
          enclosures: {
            enrichment: 'INTEGER NOT NULL DEFAULT 100',
            climate_controlled: 'INTEGER NOT NULL DEFAULT 0'
          },
          housing_events: {
            closes_housing_id: 'TEXT'
          },
          keepers: {
            worked_minutes: 'INTEGER NOT NULL DEFAULT 0'
          },
          zoo: {
            buzz: 'INTEGER NOT NULL DEFAULT 0'
          }
        }.freeze

        def initialize(path = ':memory:')
          @db = path == ':memory:' ? Sequel.sqlite : Sequel.sqlite(path)
          create_schema
          add_missing_columns
        end

        def execute(sql, *params)
          @db.fetch(sql, *params).all.map { |row| row.transform_keys(&:to_s) }
        end

        def dataset(name)
          @db[name]
        end

        def transaction
          result = nil
          @db.transaction { result = yield }
          result
        end

        def transaction_active?
          @db.in_transaction?
        end

        private

        def add_missing_columns
          ADDED_COLUMNS.each do |table, columns|
            existing = @db.schema(table).map(&:first)
            columns.except(*existing).each do |name, definition|
              @db.run("ALTER TABLE #{table} ADD COLUMN #{name} #{definition}")
            end
          end
        end

        def create_schema
          @db.run(<<~SQL)
            CREATE TABLE IF NOT EXISTS zoo (
              id            INTEGER PRIMARY KEY CHECK (id = 1),
              name          TEXT    NOT NULL,
              admission_fee INTEGER NOT NULL,
              revenue       INTEGER NOT NULL,
              visitor_count INTEGER NOT NULL,
              balance       INTEGER NOT NULL,
              reputation    REAL    NOT NULL,
              day           INTEGER NOT NULL DEFAULT 0
            );
            CREATE TABLE IF NOT EXISTS animals (
              id             TEXT PRIMARY KEY,
              species_key    TEXT    NOT NULL,
              name           TEXT    NOT NULL,
              sex            TEXT    NOT NULL,
              health_current INTEGER NOT NULL,
              health_max     INTEGER NOT NULL,
              hunger         INTEGER NOT NULL,
              stress         INTEGER NOT NULL DEFAULT 0,
              age_in_days    INTEGER NOT NULL,
              illness_key    TEXT,
              immunities     TEXT    NOT NULL DEFAULT '',
              death_cause    TEXT,
              parent_ids     TEXT    NOT NULL DEFAULT ''
            );
            CREATE TABLE IF NOT EXISTS keepers (
              id          TEXT PRIMARY KEY,
              name        TEXT NOT NULL,
              specialties TEXT NOT NULL DEFAULT ''
            );
            CREATE TABLE IF NOT EXISTS veterinarians (
              id   TEXT PRIMARY KEY,
              name TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS enclosures (
              id           TEXT PRIMARY KEY,
              name         TEXT    NOT NULL,
              celsius      INTEGER NOT NULL,
              capacity     INTEGER NOT NULL,
              cleanliness  INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS housing_events (
              seq               INTEGER PRIMARY KEY AUTOINCREMENT,
              id                TEXT    NOT NULL,
              animal_id         TEXT    NOT NULL,
              enclosure_id      TEXT,
              kind              TEXT    NOT NULL,
              occurred_on       INTEGER NOT NULL,
              keeper_id         TEXT,
              closes_housing_id TEXT
            );
            CREATE INDEX IF NOT EXISTS index_housing_events_on_animal_id ON housing_events (animal_id);
            CREATE TABLE IF NOT EXISTS events (
              id         INTEGER PRIMARY KEY AUTOINCREMENT,
              type       TEXT NOT NULL,
              animal_id  TEXT,
              cause      TEXT
            );
            CREATE TABLE IF NOT EXISTS births (
              id           TEXT PRIMARY KEY,
              sire_id      TEXT    NOT NULL,
              dam_id       TEXT    NOT NULL,
              offspring_id TEXT    NOT NULL,
              day          INTEGER NOT NULL,
              season       TEXT    NOT NULL
            );
            CREATE INDEX IF NOT EXISTS index_births_on_offspring_id ON births (offspring_id);
            CREATE TABLE IF NOT EXISTS breedings (
              id      TEXT PRIMARY KEY,
              sire_id TEXT    NOT NULL,
              dam_id  TEXT    NOT NULL,
              day     INTEGER NOT NULL,
              season  TEXT    NOT NULL
            );
            CREATE TABLE IF NOT EXISTS tendings (
              seq          INTEGER PRIMARY KEY AUTOINCREMENT,
              id           TEXT    NOT NULL UNIQUE,
              keeper_id    TEXT    NOT NULL,
              enclosure_id TEXT    NOT NULL,
              occurred_on  INTEGER NOT NULL
            );
            CREATE INDEX IF NOT EXISTS index_tendings_on_keeper_id ON tendings (keeper_id);
            CREATE TABLE IF NOT EXISTS relievings (
              seq         INTEGER PRIMARY KEY AUTOINCREMENT,
              id          TEXT    NOT NULL UNIQUE,
              tending_id  TEXT    NOT NULL,
              occurred_on INTEGER NOT NULL
            );
            CREATE INDEX IF NOT EXISTS index_relievings_on_tending_id ON relievings (tending_id);
            CREATE TABLE IF NOT EXISTS operatings (
              id             TEXT    PRIMARY KEY,
              day            INTEGER NOT NULL,
              visitors       INTEGER NOT NULL,
              income         INTEGER NOT NULL,
              cost           INTEGER NOT NULL,
              deaths         INTEGER NOT NULL,
              balance        INTEGER NOT NULL,
              reputation     INTEGER NOT NULL,
              outbreak       TEXT,
              total_visitors INTEGER NOT NULL DEFAULT 0,
              total_revenue  INTEGER NOT NULL DEFAULT 0
            );
            CREATE TABLE IF NOT EXISTS operating_expenses (
              seq          INTEGER PRIMARY KEY AUTOINCREMENT,
              operating_id TEXT    NOT NULL,
              category     TEXT    NOT NULL,
              subject      TEXT    NOT NULL,
              quantity     INTEGER NOT NULL,
              amount       INTEGER NOT NULL
            );
            CREATE INDEX IF NOT EXISTS index_operating_expenses_on_operating_id
              ON operating_expenses (operating_id);
          SQL
        end
      end
    end
  end
end
