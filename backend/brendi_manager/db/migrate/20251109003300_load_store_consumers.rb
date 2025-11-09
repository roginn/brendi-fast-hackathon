# frozen_string_literal: true

require "json"
require "time"

class LoadStoreConsumers < ActiveRecord::Migration[8.1]
  class StoreConsumer < ActiveRecord::Base
    self.table_name = "store_consumers"
  end

  def up
    return unless table_exists?(:store_consumers)

    payload = build_payload
    return if payload.empty?

    StoreConsumer.insert_all(payload)
  end

  def down
    ids = source_records.map { |record| record["id"] }.compact
    StoreConsumer.where(external_id: ids).delete_all if ids.any?
  end

  private

  def build_payload
    records = source_records
    return [] unless records

    records.map do |record|
      next unless record.is_a?(Hash)

      {
        external_id: record["id"],
        mongo_id: record["mongo_id"],
        store_id: record["store_id"],
        menu_slug: record["menu_slug"],
        name: record["name"],
        phone: record["phone"],
        bot_optout: record["bot_optout"],
        campaign_optout: record["campaign_optout"],
        from_ad_message: record["from_ad_message"],
        vip: record["vip"],
        number_of_orders: record["number_of_orders"],
        recovery_campaigns_received: record["recovery_campaigns_received"],
        ctwa_clid: record["ctwa_clid"],
        source_app: record["source_app"],
        source_id: record["source_id"],
        type_label: record["type"],
        platforms: record["platforms"],
        extra_info: record["extra_info"],
        last_address: record["last_address"],
        last_order_date: parse_iso_time(record["last_order_date"]),
        last_received_campaign: parse_iso_time(record["last_received_campaign"]),
        last_received_custom: parse_iso_time(record["last_received_custom"]),
        created_at: parse_iso_time(record["created_at"]),
        updated_at: parse_iso_time(record["updated_at"]),
        raw_data: record
      }
    end.compact
  end

  def source_records
    return @source_records if defined?(@source_records)

    file_path = Rails.root.join("..", "..", "json_files", "store_consumers.json")
    @source_records =
      if File.exist?(file_path)
        JSON.parse(File.binread(file_path))
      else
        warn "store_consumers.json not found, skipping store consumers import"
        nil
      end
  rescue JSON::ParserError => e
    warn "Failed to parse store_consumers.json: #{e.message}"
    nil
  end

  def parse_iso_time(value)
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

