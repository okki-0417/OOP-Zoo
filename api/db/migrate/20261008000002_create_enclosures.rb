# frozen_string_literal: true

class CreateEnclosures < ActiveRecord::Migration[8.1]
  def change
    create_table :enclosures do |t|
      t.string :name, null: false
      t.float :temperature, null: false
      t.integer :capacity, null: false
      t.integer :area_sqm
      t.boolean :climate_controlled, null: false, default: false
      t.integer :cleanliness, null: false
      t.integer :enrichment, null: false
      t.timestamps
    end
  end
end
