class CreateEnclosures < ActiveRecord::Migration[8.1]
  def change
    create_table :enclosures do |t|
      t.string :name, null: false
      t.integer :celsius, null: false
      t.integer :capacity, null: false
      t.integer :cleanliness, null: false, default: 100
      t.integer :enrichment, null: false, default: 100
      t.integer :area_sqm
      t.boolean :climate_controlled, null: false, default: false

      t.timestamps
    end
  end
end
