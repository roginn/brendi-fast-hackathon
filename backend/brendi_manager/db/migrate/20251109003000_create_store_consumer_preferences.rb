# frozen_string_literal: true

class CreateStoreConsumerPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :store_consumer_preferences do |t|
      t.string :external_id
      t.string :store_consumer_id
      t.integer :best_campaign_hour
      t.string :best_campaign_weekday
      t.boolean :bot_optout
      t.boolean :campaign_optout
      t.integer :last_order_hour
      t.string :last_order_weekday
      t.jsonb :raw_data, default: {}
      t.datetime :created_at, precision: 6
      t.datetime :updated_at, precision: 6

      t.index :external_id
      t.index :store_consumer_id
    end
  end
end

