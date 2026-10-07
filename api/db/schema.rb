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

ActiveRecord::Schema[8.1].define(version: 2026_10_08_000008) do
  create_table "animals", force: :cascade do |t|
    t.string "species", null: false
    t.string "name", null: false
    t.string "sex", null: false
    t.integer "age_in_days", default: 0, null: false
    t.integer "current_health", null: false
    t.integer "max_health", null: false
    t.integer "hunger", null: false
    t.integer "stress", null: false
    t.integer "nutrition", null: false
    t.string "meals", default: "", null: false
    t.string "illness"
    t.string "immunities", default: "", null: false
    t.string "pregnancy_sex"
    t.integer "gestation_days"
    t.float "pregnancy_inbreeding"
    t.boolean "miscarried", default: false, null: false
    t.string "death_cause"
    t.integer "enclosure_id"
    t.integer "sire_id"
    t.integer "dam_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dam_id"], name: "index_animals_on_dam_id"
    t.index ["enclosure_id"], name: "index_animals_on_enclosure_id"
    t.index ["sire_id"], name: "index_animals_on_sire_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "keeper_id", null: false
    t.integer "enclosure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enclosure_id"], name: "index_assignments_on_enclosure_id"
    t.index ["keeper_id", "enclosure_id"], name: "index_assignments_on_keeper_id_and_enclosure_id", unique: true
    t.index ["keeper_id"], name: "index_assignments_on_keeper_id"
  end

  create_table "breedings", force: :cascade do |t|
    t.integer "sire_id", null: false
    t.integer "dam_id", null: false
    t.integer "day", null: false
    t.string "season", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dam_id"], name: "index_breedings_on_dam_id"
    t.index ["sire_id"], name: "index_breedings_on_sire_id"
  end

  create_table "enclosures", force: :cascade do |t|
    t.string "name", null: false
    t.float "temperature", null: false
    t.integer "capacity", null: false
    t.integer "area_sqm"
    t.boolean "climate_controlled", default: false, null: false
    t.integer "cleanliness", null: false
    t.integer "enrichment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keepers", force: :cascade do |t|
    t.string "name", null: false
    t.string "specialties", null: false
    t.integer "worked_minutes", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "operatings", force: :cascade do |t|
    t.integer "day", null: false
    t.integer "visitors", null: false
    t.integer "income", null: false
    t.integer "cost", null: false
    t.text "expenses", null: false
    t.integer "deaths", null: false
    t.integer "balance", null: false
    t.integer "reputation", null: false
    t.string "outbreak"
    t.integer "total_visitors", null: false
    t.integer "total_revenue", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_operatings_on_day"
  end

  create_table "veterinarians", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "zoos", force: :cascade do |t|
    t.string "name", null: false
    t.integer "admission_fee", null: false
    t.integer "revenue", default: 0, null: false
    t.integer "visitor_count", default: 0, null: false
    t.integer "balance", default: 0, null: false
    t.float "reputation", null: false
    t.integer "day", default: 0, null: false
    t.integer "buzz", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "animals", "animals", column: "dam_id"
  add_foreign_key "animals", "animals", column: "sire_id"
  add_foreign_key "animals", "enclosures"
  add_foreign_key "assignments", "enclosures"
  add_foreign_key "assignments", "keepers"
  add_foreign_key "breedings", "animals", column: "dam_id"
  add_foreign_key "breedings", "animals", column: "sire_id"
end
