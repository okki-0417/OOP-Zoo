# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :keeper, null: false, foreign_key: true
      t.references :enclosure, null: false, foreign_key: true
      t.timestamps
    end
    add_index :assignments, %i[keeper_id enclosure_id], unique: true
  end
end
