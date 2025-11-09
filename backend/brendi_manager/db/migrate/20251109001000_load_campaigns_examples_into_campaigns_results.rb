# frozen_string_literal: true

require "json"
require "time"

class LoadCampaignsExamplesIntoCampaignsResults < ActiveRecord::Migration[8.1]
  class CampaignsResult < ActiveRecord::Base
    self.table_name = "campaigns_results"
  end

  def up
    records = read_records
    return if records.empty?

    payload = records.map { |record| build_attributes(record) }.compact
    CampaignsResult.insert_all(payload) if payload.any?
  end

  def down
    records = read_records
    return if records.empty?

    ids = records.filter_map { |record| record["id"] }
    CampaignsResult.where(external_id: ids).delete_all if ids.any?
  end

  private

  def read_records
    file_path = Rails.root.join("..", "..", "json_files", "campaigns_results.json")
    return [] unless File.exist?(file_path)

    parsed = JSON.parse(File.binread(file_path))
    Array(parsed)
  rescue JSON::ParserError => e
    warn "Failed to parse campaigns_examples.json: #{e.message}"
    []
  end

  def build_attributes(record)
    return unless record.is_a?(Hash)

    {
      external_id: record["id"],
      mongo_id: record["mongo_id"],
      campaign_id: record["campaign_id"],
      store_id: record["store_id"],
      menu_slug: record["menu_slug"],
      store_phone: record["store_phone"],
      targeting: record["targeting"],
      is_custom: record["is_custom"],
      payload: record["payload"],
      media: record["media"],
      voucher: record["voucher"],
      send_status: record["send_status"],
      conversion_rate: record["conversion_rate"],
      evasion_rate: record["evasion_rate"],
      order_ids: record["order_ids"],
      orders_delivered: record["orders_delivered"],
      total_order_value: record["total_order_value"],
      timestamp: parse_timestamp(record["timestamp"]),
      end_timestamp: parse_timestamp(record["end_timestamp"]),
      created_at: parse_timestamp(record["created_at"]),
      updated_at: parse_timestamp(record["updated_at"])
    }
  end

  def parse_timestamp(value)
    case value
    when String
      Time.iso8601(value)
    when Hash
      iso = value["iso"]
      iso ? Time.iso8601(iso) : nil
    else
      nil
    end
  rescue ArgumentError
    nil
  end
end

