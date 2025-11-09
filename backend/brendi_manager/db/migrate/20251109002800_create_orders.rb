# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :external_id
      t.string :uuid
      t.string :code
      t.string :status
      t.integer :total_price
      t.boolean :hidden
      t.boolean :is_scheduled
      t.string :integration_status
      t.jsonb :customer
      t.jsonb :delivery
      t.jsonb :discount
      t.jsonb :payment
      t.jsonb :timeline
      t.jsonb :products
      t.jsonb :raw_data, default: {}
      t.datetime :created_at, precision: 6
      t.datetime :updated_at, precision: 6
      t.datetime :confirmed_at, precision: 6
      t.datetime :delivered_at, precision: 6

      t.index :external_id
      t.index :code
      t.index :status
      t.index :created_at
    end
  end
end

