# frozen_string_literal: true

class CreateOperatings < ActiveRecord::Migration[8.1]
  def change
    create_table :operatings do |t|
      t.integer :day, null: false
      t.integer :visitors, null: false
      t.integer :income, null: false
      t.integer :cost, null: false
      t.text :expenses, null: false
      t.integer :deaths, null: false
      t.integer :balance, null: false
      t.integer :reputation, null: false
      t.string :outbreak
      t.integer :total_visitors, null: false
      t.integer :total_revenue, null: false
      t.timestamps
    end
    add_index :operatings, :day
  end
end
