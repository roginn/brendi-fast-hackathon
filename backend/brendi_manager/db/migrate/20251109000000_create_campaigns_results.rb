# frozen_string_literal: true

class CreateCampaignsResults < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns_results do |t|
      t.string :external_id
      t.string :mongo_id
      t.string :campaign_id
      t.string :store_id
      t.string :menu_slug
      t.string :store_phone
      t.string :targeting
      t.boolean :is_custom, default: false
      t.text :payload
      t.jsonb :media
      t.jsonb :voucher
      t.jsonb :send_status, default: {}
      t.decimal :conversion_rate, precision: 10, scale: 4
      t.decimal :evasion_rate, precision: 10, scale: 4
      t.jsonb :order_ids
      t.integer :orders_delivered
      t.string :total_order_value
      t.datetime :timestamp, precision: 6
      t.datetime :end_timestamp, precision: 6
      t.datetime :created_at, precision: 6
      t.datetime :updated_at, precision: 6

      t.index :external_id
      t.index :campaign_id
      t.index :store_id
      t.index :timestamp
      t.index :is_custom
    end
  end
end

