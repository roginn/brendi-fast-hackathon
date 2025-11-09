# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.string :external_id
      t.string :store_id
      t.string :store_consumer_id
      t.string :order_id
      t.string :category
      t.integer :rating
      t.text :rated_response
      t.jsonb :raw_data, default: {}
      t.datetime :created_at, precision: 6
      t.datetime :updated_at, precision: 6

      t.index :external_id
      t.index :store_id
      t.index :store_consumer_id
      t.index :order_id
    end
  end
end

