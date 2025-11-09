# frozen_string_literal: true

class CreateStoreConsumers < ActiveRecord::Migration[8.1]
  def change
    create_table :store_consumers do |t|
      t.string :external_id
      t.string :mongo_id
      t.string :store_id
      t.string :menu_slug
      t.string :name
      t.string :phone
      t.boolean :bot_optout
      t.boolean :campaign_optout
      t.boolean :from_ad_message
      t.boolean :vip
      t.integer :number_of_orders
      t.integer :recovery_campaigns_received
      t.string :ctwa_clid
      t.string :source_app
      t.string :source_id
      t.string :type_label
      t.jsonb :platforms
      t.jsonb :extra_info
      t.jsonb :last_address
      t.datetime :last_order_date, precision: 6
      t.datetime :last_received_campaign, precision: 6
      t.datetime :last_received_custom, precision: 6
      t.datetime :created_at, precision: 6
      t.datetime :updated_at, precision: 6
      t.jsonb :raw_data, default: {}

      t.index :external_id
      t.index :store_id
      t.index :menu_slug
      t.index :phone
      t.index :number_of_orders
    end
  end
end

