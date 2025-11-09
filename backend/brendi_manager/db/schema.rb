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

ActiveRecord::Schema[8.1].define(version: 2025_11_09_001000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "campaigns_results", force: :cascade do |t|
    t.string "campaign_id"
    t.decimal "conversion_rate", precision: 10, scale: 4
    t.datetime "created_at"
    t.datetime "end_timestamp"
    t.decimal "evasion_rate", precision: 10, scale: 4
    t.string "external_id"
    t.boolean "is_custom", default: false
    t.jsonb "media"
    t.string "menu_slug"
    t.string "mongo_id"
    t.jsonb "order_ids"
    t.integer "orders_delivered"
    t.text "payload"
    t.jsonb "send_status", default: {}
    t.string "store_id"
    t.string "store_phone"
    t.string "targeting"
    t.datetime "timestamp"
    t.string "total_order_value"
    t.datetime "updated_at"
    t.jsonb "voucher"
    t.index ["campaign_id"], name: "index_campaigns_results_on_campaign_id"
    t.index ["external_id"], name: "index_campaigns_results_on_external_id"
    t.index ["is_custom"], name: "index_campaigns_results_on_is_custom"
    t.index ["store_id"], name: "index_campaigns_results_on_store_id"
    t.index ["timestamp"], name: "index_campaigns_results_on_timestamp"
  end
end
