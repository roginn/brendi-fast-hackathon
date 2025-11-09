# frozen_string_literal: true

require "json"
require "time"

class LoadCampaigns < ActiveRecord::Migration[8.1]
  class Campaign < ActiveRecord::Base
    self.table_name = "campaigns"
  end

  def up
    return unless table_exists?(:campaigns)

    payload = build_payload
    return if payload.empty?

    Campaign.insert_all(payload)
  end

  def down
    ids = source_records.map { |record| record["id"] }.compact
    Campaign.where(external_id: ids).delete_all if ids.any?
  end

  private

  def build_payload
    records = source_records
    return [] unless records

    records.map do |record|
      next unless record.is_a?(Hash)

      {
        external_id: record["id"],
        campaign_id: record["campaign_id"],
        store_id: record["store_id"],
        status: record["status"],
        targeting: record["targeting"],
        campaign_type: record["type"],
        use_voucher: record["use_voucher"],
        description: record["description"],
        date: record["date"],
        limit_value: safe_integer(record["limit"]),
        message_content_risk: record["message_content_risk"],
        message_volume_risk: record["message_volume_risk"],
        payload: record["payload"],
        media: record["media"],
        voucher: record["voucher"],
        raw_data: record,
        created_at: parse_iso_time(record["created_at"]),
        updated_at: parse_iso_time(record["updated_at"])
      }
    end.compact
  end

  def source_records
    return @source_records if defined?(@source_records)

    file_path = Rails.root.join("..", "..", "json_files", "campaigns.json")
    @source_records =
      if File.exist?(file_path)
        JSON.parse(File.binread(file_path))
      else
        warn "campaigns.json not found, skipping campaigns import"
        nil
      end
  rescue JSON::ParserError => e
    warn "Failed to parse campaigns.json: #{e.message}"
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

  def safe_integer(value)
    return nil if value.nil?
    return value if value.is_a?(Integer)

    Integer(value, exception: false)
  end
end

