# frozen_string_literal: true

class CreateMenuEventsLast30Days < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_events_last_30_days do |t|
      t.string :external_id
      t.datetime :created_at, precision: 6
      t.string :event_type
      t.string :device_type
      t.string :platform
      t.text :referrer
      t.string :session_id
      t.string :store_id
      t.datetime :event_timestamp, precision: 6
      t.jsonb :metadata
      t.jsonb :raw_data, default: {}

      t.index :external_id
      t.index :store_id
      t.index :session_id
      t.index :event_type
    end
  end
end

