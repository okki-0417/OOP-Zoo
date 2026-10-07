# frozen_string_literal: true

class CreateAnimals < ActiveRecord::Migration[8.1]
  def change
    create_table :animals do |t|
      t.string :species, null: false
      t.string :name, null: false
      t.string :sex, null: false
      t.integer :age_in_days, null: false, default: 0
      t.integer :current_health, null: false
      t.integer :max_health, null: false
      t.integer :hunger, null: false
      t.integer :stress, null: false
      t.integer :nutrition, null: false
      t.string :meals, null: false, default: ''
      t.string :illness
      t.string :immunities, null: false, default: ''
      t.string :pregnancy_sex
      t.integer :gestation_days
      t.float :pregnancy_inbreeding
      t.boolean :miscarried, null: false, default: false
      t.string :death_cause
      t.references :enclosure, foreign_key: true
      t.references :sire, foreign_key: { to_table: :animals }
      t.references :dam, foreign_key: { to_table: :animals }
      t.timestamps
    end
  end
end
