# frozen_string_literal: true

require "json"
require "time"

class LoadOrders < ActiveRecord::Migration[8.1]
  class Order < ActiveRecord::Base
    self.table_name = "orders"
  end

  TIMESTAMP_FIELDS = %w[createdAt updatedAt confirmedAt deliveredAt].freeze

  def up
    return unless table_exists?(:orders)

    each_source_record(missing_message: "orders.jsonl not found, skipping orders import") do |record|
      attributes = build_attributes(record)
      next unless attributes

      Order.insert_all([attributes])
    end
  end

  def down
    return unless table_exists?(:orders)

    each_source_record(missing_message: "orders.jsonl not found, unable to rollback orders import") do |record|
      external_id = record["id"]
      next unless external_id

      Order.where(external_id: external_id).delete_all
    end
  end

  private

  def each_source_record(missing_message:)
    file_path = jsonl_file_path
    unless File.exist?(file_path)
      warn missing_message
      return
    end

    File.foreach(file_path, chomp: true).with_index(1) do |line, line_number|
      next if line.strip.empty?

      record = parse_line(line, line_number)
      next unless record.is_a?(Hash)

      yield record
    end
  end

  def parse_line(line, line_number)
    JSON.parse(line)
  rescue JSON::ParserError => e
    warn "Failed to parse orders.jsonl line #{line_number}: #{e.message}"
    nil
  end

  def build_attributes(record)
    {
      external_id: record["id"],
      uuid: record["uuid"],
      code: record["code"],
      status: record["status"],
      total_price: record["totalPrice"],
      hidden: record["hidden"],
      is_scheduled: record["isScheduled"],
      integration_status: record["integrationStatus"],
      customer: record["customer"],
      delivery: record["delivery"],
      discount: record["discount"],
      payment: record["payment"],
      timeline: record["timeline"],
      products: record["products"],
      raw_data: record,
      created_at: parse_timestamp(record["createdAt"]),
      updated_at: parse_timestamp(record["updatedAt"]),
      confirmed_at: parse_timestamp(record["confirmedAt"]),
      delivered_at: parse_timestamp(record["deliveredAt"])
    }
  end

  def jsonl_file_path
    Rails.root.join("..", "..", "json_files", "orders.jsonl")
  end

  def parse_timestamp(value)
    case value
    when Hash
      iso = value["iso"]
      iso ? Time.iso8601(iso) : nil
    when String
      Time.iso8601(value)
    else
      nil
    end
  rescue ArgumentError
    nil
  end
end

