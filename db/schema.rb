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

ActiveRecord::Schema[8.1].define(version: 2026_03_15_035415) do
  create_table "devices", force: :cascade do |t|
    t.string "brand"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "location"
    t.string "mac_address"
    t.string "model_number"
    t.string "name", null: false
    t.text "notes"
    t.integer "parent_device_id"
    t.date "purchased_at"
    t.string "serial_number"
    t.string "status", default: "active"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.date "warranty_expires_at"
    t.index ["parent_device_id"], name: "index_devices_on_parent_device_id"
    t.index ["status"], name: "index_devices_on_status"
    t.index ["type"], name: "index_devices_on_type"
  end

  create_table "interventions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "device_id", null: false
    t.integer "duration_minutes"
    t.date "intervened_at", null: false
    t.string "intervention_type", null: false
    t.text "parts_replaced"
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_interventions_on_device_id"
  end

  add_foreign_key "interventions", "devices"
end
