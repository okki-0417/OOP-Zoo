# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_03_071850) do
  create_table "animals", force: :cascade do |t|
    t.integer "age_in_days", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "dam_id"
    t.string "death_cause"
    t.integer "health_current", null: false
    t.integer "health_max", null: false
    t.integer "hunger", null: false
    t.string "illness_key"
    t.json "immunities", default: [], null: false
    t.boolean "miscarried", default: false, null: false
    t.string "name", null: false
    t.integer "nutrition", default: 100, null: false
    t.integer "pregnancy_gestation_days"
    t.float "pregnancy_inbreeding_coefficient"
    t.string "pregnancy_sex"
    t.string "sex", null: false
    t.bigint "sire_id"
    t.string "species_key", null: false
    t.integer "stress", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "enclosures", force: :cascade do |t|
    t.integer "area_sqm"
    t.integer "capacity", null: false
    t.integer "celsius", null: false
    t.integer "cleanliness", default: 100, null: false
    t.boolean "climate_controlled", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "enrichment", default: 100, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "housing_events", force: :cascade do |t|
    t.integer "animal_id", null: false
    t.integer "closes_housing_id"
    t.datetime "created_at", null: false
    t.integer "enclosure_id"
    t.bigint "keeper_id"
    t.integer "occurred_on", default: 0, null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["animal_id"], name: "index_housing_events_on_animal_id"
    t.index ["closes_housing_id"], name: "index_housing_events_on_closes_housing_id"
    t.index ["enclosure_id"], name: "index_housing_events_on_enclosure_id"
  end

  add_foreign_key "housing_events", "animals"
  add_foreign_key "housing_events", "enclosures"
  add_foreign_key "housing_events", "housing_events", column: "closes_housing_id"
end
