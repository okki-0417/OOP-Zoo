# frozen_string_literal: true

class CreateKeepers < ActiveRecord::Migration[8.1]
  def change
    create_table :keepers do |t|
      t.string :name, null: false
      t.string :specialties, null: false
      t.integer :worked_minutes, null: false, default: 0
      t.timestamps
    end
  end
end
