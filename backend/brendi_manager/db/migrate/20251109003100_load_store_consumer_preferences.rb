# frozen_string_literal: true

require "json"
require "time"

class LoadStoreConsumerPreferences < ActiveRecord::Migration[8.1]
  class StoreConsumerPreference < ActiveRecord::Base
    self.table_name = "store_consumer_preferences"
  end

  def up
    return unless table_exists?(:store_consumer_preferences)

    payload = build_payload
    return if payload.empty?

    StoreConsumerPreference.insert_all(payload)
  end

  def down
    ids = source_records.map { |record| record["id"] }.compact
    StoreConsumerPreference.where(external_id: ids).delete_all if ids.any?
  end

  private

  def build_payload
    records = source_records
    return [] unless records

    records.map do |record|
      next unless record.is_a?(Hash)

      {
        external_id: record["id"],
        store_consumer_id: record["store_consumer_id"],
        best_campaign_hour: record["best_campaign_hour"],
        best_campaign_weekday: record["best_campaign_weekday"],
        bot_optout: record["bot_optout"],
        campaign_optout: record["campaign_optout"],
        last_order_hour: record["last_order_hour"],
        last_order_weekday: record["last_order_weekday"],
        raw_data: record,
        created_at: parse_iso_time(record["created_at"]),
        updated_at: parse_iso_time(record["updated_at"])
      }
    end.compact
  end

  def source_records
    return @source_records if defined?(@source_records)

    file_path = Rails.root.join("..", "..", "json_files", "store_consumer_preferences.json")
    @source_records =
      if File.exist?(file_path)
        JSON.parse(File.binread(file_path))
      else
        warn "store_consumer_preferences.json not found, skipping preferences import"
        nil
      end
  rescue JSON::ParserError => e
    warn "Failed to parse store_consumer_preferences.json: #{e.message}"
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

