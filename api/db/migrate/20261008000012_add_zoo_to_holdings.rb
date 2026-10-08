# frozen_string_literal: true

class AddZooToHoldings < ActiveRecord::Migration[8.1]
  TABLES = %i[animals enclosures keepers veterinarians operatings].freeze

  def up
    TABLES.each do |table|
      add_reference table, :zoo, foreign_key: true
      execute("UPDATE #{table} SET zoo_id = (SELECT MIN(id) FROM zoos)")
      change_column_null table, :zoo_id, false
    end
  end

  def down
    TABLES.each { |table| remove_reference table, :zoo }
  end
end
