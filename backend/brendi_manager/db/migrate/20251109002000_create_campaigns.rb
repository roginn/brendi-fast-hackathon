# frozen_string_literal: true

class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string :external_id
      t.string :campaign_id
      t.string :store_id
      t.string :status
      t.string :targeting
      t.string :campaign_type
      t.boolean :use_voucher
      t.text :description
      t.string :date
      t.integer :limit_value
      t.string :message_content_risk
      t.string :message_volume_risk
      t.text :payload
      t.jsonb :media
      t.jsonb :voucher
      t.jsonb :raw_data, default: {}
      t.datetime :created_at, precision: 6
      t.datetime :updated_at, precision: 6

      t.index :external_id
      t.index :campaign_id
      t.index :store_id
      t.index :status
      t.index :targeting
    end
  end
end

