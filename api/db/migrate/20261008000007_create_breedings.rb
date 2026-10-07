# frozen_string_literal: true

class CreateBreedings < ActiveRecord::Migration[8.1]
  def change
    create_table :breedings do |t|
      t.references :sire, null: false, foreign_key: { to_table: :animals }
      t.references :dam, null: false, foreign_key: { to_table: :animals }
      t.integer :day, null: false
      t.string :season, null: false
      t.timestamps
    end
  end
end
