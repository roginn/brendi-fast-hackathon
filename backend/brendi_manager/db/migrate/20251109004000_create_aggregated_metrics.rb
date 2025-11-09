class CreateAggregatedMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :aggregated_metrics do |t|
      t.string :name, null: false
      t.text :sql_query, null: false
      t.jsonb :result, null: false, default: {}

      t.timestamps
    end

    add_index :aggregated_metrics, :name
    add_index :aggregated_metrics, :created_at
  end
end

