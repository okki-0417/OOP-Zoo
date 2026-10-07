# frozen_string_literal: true

class CreateZoos < ActiveRecord::Migration[8.1]
  def change
    create_table :zoos do |t|
      t.string :name, null: false
      t.integer :admission_fee, null: false
      t.integer :revenue, null: false, default: 0
      t.integer :visitor_count, null: false, default: 0
      t.integer :balance, null: false, default: 0
      t.float :reputation, null: false
      t.integer :day, null: false, default: 0
      t.integer :buzz, null: false, default: 0
      t.timestamps
    end
  end
end
