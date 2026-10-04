class CreateHousingEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :housing_events do |t|
      t.string :type, null: false
      t.references :animal, null: false, foreign_key: true
      t.references :enclosure, foreign_key: true
      t.integer :occurred_on, null: false, default: 0
      t.bigint :keeper_id
      t.references :closes_housing, foreign_key: { to_table: :housing_events }

      t.timestamps
    end
  end
end
