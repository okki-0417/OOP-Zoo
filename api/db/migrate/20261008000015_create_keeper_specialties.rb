# frozen_string_literal: true

class CreateKeeperSpecialties < ActiveRecord::Migration[8.1]
  def up
    create_table :keeper_specialties do |t|
      t.references :keeper, null: false, foreign_key: true
      t.string :taxon_class, null: false
      t.timestamps
    end
    add_index :keeper_specialties, %i[keeper_id taxon_class], unique: true

    select_rows("SELECT id, specialties FROM keepers WHERE specialties <> ''").each do |keeper_id, specialties|
      specialties.split(',').uniq.each do |taxon_class|
        execute(<<~SQL.squish)
          INSERT INTO keeper_specialties (keeper_id, taxon_class, created_at, updated_at)
          VALUES (#{keeper_id}, #{quote(taxon_class)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      end
    end

    remove_column :keepers, :specialties
  end

  def down
    add_column :keepers, :specialties, :string, null: false, default: ''
    execute(<<~SQL.squish)
      UPDATE keepers SET specialties = COALESCE(
        (SELECT GROUP_CONCAT(taxon_class, ',') FROM keeper_specialties WHERE keeper_specialties.keeper_id = keepers.id), ''
      )
    SQL
    drop_table :keeper_specialties
  end
end
