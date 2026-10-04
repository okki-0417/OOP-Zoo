class CreateAnimals < ActiveRecord::Migration[8.1]
  def change
    create_table :animals do |t|
      t.string :species_key, null: false
      t.string :name, null: false
      t.string :sex, null: false
      t.integer :health_current, null: false
      t.integer :health_max, null: false
      t.integer :hunger, null: false
      t.integer :stress, null: false, default: 0
      t.integer :nutrition, null: false, default: 100
      t.integer :age_in_days, null: false, default: 0
      t.string :illness_key
      t.json :immunities, null: false, default: []
      t.string :death_cause
      t.bigint :sire_id
      t.bigint :dam_id
      t.string :pregnancy_sex
      t.integer :pregnancy_gestation_days
      t.float :pregnancy_inbreeding_coefficient
      t.boolean :miscarried, null: false, default: false

      t.timestamps
    end
  end
end
