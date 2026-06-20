# frozen_string_literal: true

require 'sqlite3'

module Zoo
  module Infrastructure
    module Sqlite
      class Database
        def initialize(path = ':memory:')
          @db = SQLite3::Database.new(path)
          @db.results_as_hash = true
          create_schema
        end

        def get_first_row(sql, *params)
          @db.get_first_row(sql, params)
        end

        def execute(sql, *params)
          @db.execute(sql, params)
        end

        def transaction
          result = nil
          @db.transaction { result = yield }
          result
        end

        def transaction_active?
          @db.transaction_active?
        end

        private

        def create_schema
          @db.execute_batch(<<~SQL)
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
              cleanliness  INTEGER NOT NULL,
              occupant_ids TEXT    NOT NULL DEFAULT ''
            );
            CREATE TABLE IF NOT EXISTS events (
              id         INTEGER PRIMARY KEY AUTOINCREMENT,
              type       TEXT NOT NULL,
              animal_id  TEXT,
              cause      TEXT
            );
            CREATE TABLE IF NOT EXISTS births (
              id           INTEGER PRIMARY KEY AUTOINCREMENT,
              sire_id      TEXT    NOT NULL,
              dam_id       TEXT    NOT NULL,
              offspring_id TEXT    NOT NULL,
              occurred_on  INTEGER NOT NULL,
              season       TEXT    NOT NULL,
              keeper_id    TEXT
            );
            CREATE TABLE IF NOT EXISTS breedings (
              id      TEXT PRIMARY KEY,
              sire_id TEXT    NOT NULL,
              dam_id  TEXT    NOT NULL,
              day     INTEGER NOT NULL,
              season  TEXT    NOT NULL
            );
            CREATE TABLE IF NOT EXISTS namings (
              id          INTEGER PRIMARY KEY AUTOINCREMENT,
              animal_id   TEXT    NOT NULL,
              name        TEXT    NOT NULL,
              keeper_id   TEXT,
              occurred_on INTEGER NOT NULL
            );
          SQL
        end
      end
    end
  end
end
