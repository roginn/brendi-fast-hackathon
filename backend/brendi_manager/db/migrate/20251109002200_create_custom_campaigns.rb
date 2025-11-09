# frozen_string_literal: true

class CreateCustomCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_campaigns do |t|
      t.string :external_id
      t.string :description
      t.datetime :date, precision: 6
      t.jsonb :payload
      t.jsonb :voucher
      t.string :targeting
      t.string :limit_value
      t.jsonb :media
      t.string :status
      t.string :risk_level
      t.boolean :post_on_status
      t.jsonb :reference
      t.jsonb :raw_data, default: {}
      t.datetime :created_at, precision: 6

      t.index :external_id
      t.index :targeting
      t.index :status
    end
  end
end

