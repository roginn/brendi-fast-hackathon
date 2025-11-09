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

ActiveRecord::Schema[8.1].define(version: 2025_11_09_004000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "aggregated_metrics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.jsonb "result", default: {}, null: false
    t.text "sql_query", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_aggregated_metrics_on_created_at"
    t.index ["name"], name: "index_aggregated_metrics_on_name"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "campaign_id"
    t.string "campaign_type"
    t.datetime "created_at"
    t.string "date"
    t.text "description"
    t.string "external_id"
    t.integer "limit_value"
    t.jsonb "media"
    t.string "message_content_risk"
    t.string "message_volume_risk"
    t.text "payload"
    t.jsonb "raw_data", default: {}
    t.string "status"
    t.string "store_id"
    t.string "targeting"
    t.datetime "updated_at"
    t.boolean "use_voucher"
    t.jsonb "voucher"
    t.index ["campaign_id"], name: "index_campaigns_on_campaign_id"
    t.index ["external_id"], name: "index_campaigns_on_external_id"
    t.index ["status"], name: "index_campaigns_on_status"
    t.index ["store_id"], name: "index_campaigns_on_store_id"
    t.index ["targeting"], name: "index_campaigns_on_targeting"
  end

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

  create_table "custom_campaigns", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "date"
    t.string "description"
    t.string "external_id"
    t.string "limit_value"
    t.jsonb "media"
    t.jsonb "payload"
    t.boolean "post_on_status"
    t.jsonb "raw_data", default: {}
    t.jsonb "reference"
    t.string "risk_level"
    t.string "status"
    t.string "targeting"
    t.jsonb "voucher"
    t.index ["external_id"], name: "index_custom_campaigns_on_external_id"
    t.index ["status"], name: "index_custom_campaigns_on_status"
    t.index ["targeting"], name: "index_custom_campaigns_on_targeting"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at"
    t.string "external_id"
    t.string "order_id"
    t.text "rated_response"
    t.integer "rating"
    t.jsonb "raw_data", default: {}
    t.string "store_consumer_id"
    t.string "store_id"
    t.datetime "updated_at"
    t.index ["external_id"], name: "index_feedbacks_on_external_id"
    t.index ["order_id"], name: "index_feedbacks_on_order_id"
    t.index ["store_consumer_id"], name: "index_feedbacks_on_store_consumer_id"
    t.index ["store_id"], name: "index_feedbacks_on_store_id"
  end

  create_table "menu_events_last_30_days", force: :cascade do |t|
    t.datetime "created_at"
    t.string "device_type"
    t.datetime "event_timestamp"
    t.string "event_type"
    t.string "external_id"
    t.jsonb "metadata"
    t.string "platform"
    t.jsonb "raw_data", default: {}
    t.text "referrer"
    t.string "session_id"
    t.string "store_id"
    t.index ["event_type"], name: "index_menu_events_last_30_days_on_event_type"
    t.index ["external_id"], name: "index_menu_events_last_30_days_on_external_id"
    t.index ["session_id"], name: "index_menu_events_last_30_days_on_session_id"
    t.index ["store_id"], name: "index_menu_events_last_30_days_on_store_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "code"
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.jsonb "customer"
    t.datetime "delivered_at"
    t.jsonb "delivery"
    t.jsonb "discount"
    t.string "external_id"
    t.boolean "hidden"
    t.string "integration_status"
    t.boolean "is_scheduled"
    t.jsonb "payment"
    t.jsonb "products"
    t.jsonb "raw_data", default: {}
    t.string "status"
    t.jsonb "timeline"
    t.integer "total_price"
    t.datetime "updated_at"
    t.string "uuid"
    t.index ["code"], name: "index_orders_on_code"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["external_id"], name: "index_orders_on_external_id"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "store_consumer_preferences", force: :cascade do |t|
    t.integer "best_campaign_hour"
    t.string "best_campaign_weekday"
    t.boolean "bot_optout"
    t.boolean "campaign_optout"
    t.datetime "created_at"
    t.string "external_id"
    t.integer "last_order_hour"
    t.string "last_order_weekday"
    t.jsonb "raw_data", default: {}
    t.string "store_consumer_id"
    t.datetime "updated_at"
    t.index ["external_id"], name: "index_store_consumer_preferences_on_external_id"
    t.index ["store_consumer_id"], name: "index_store_consumer_preferences_on_store_consumer_id"
  end

  create_table "store_consumers", force: :cascade do |t|
    t.boolean "bot_optout"
    t.boolean "campaign_optout"
    t.datetime "created_at"
    t.string "ctwa_clid"
    t.string "external_id"
    t.jsonb "extra_info"
    t.boolean "from_ad_message"
    t.jsonb "last_address"
    t.datetime "last_order_date"
    t.datetime "last_received_campaign"
    t.datetime "last_received_custom"
    t.string "menu_slug"
    t.string "mongo_id"
    t.string "name"
    t.integer "number_of_orders"
    t.string "phone"
    t.jsonb "platforms"
    t.jsonb "raw_data", default: {}
    t.integer "recovery_campaigns_received"
    t.string "source_app"
    t.string "source_id"
    t.string "store_id"
    t.string "type_label"
    t.datetime "updated_at"
    t.boolean "vip"
    t.index ["external_id"], name: "index_store_consumers_on_external_id"
    t.index ["menu_slug"], name: "index_store_consumers_on_menu_slug"
    t.index ["number_of_orders"], name: "index_store_consumers_on_number_of_orders"
    t.index ["phone"], name: "index_store_consumers_on_phone"
    t.index ["store_id"], name: "index_store_consumers_on_store_id"
  end
end
