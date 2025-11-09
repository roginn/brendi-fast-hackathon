# frozen_string_literal: true

require "json"
require "time"

class LoadCustomCampaigns < ActiveRecord::Migration[8.1]
  class CustomCampaign < ActiveRecord::Base
    self.table_name = "custom_campaigns"
  end

  def up
    return unless table_exists?(:custom_campaigns)

    payload = build_payload
    return if payload.empty?

    CustomCampaign.insert_all(payload)
  end

  def down
    ids = source_records.map { |record| record["id"] }.compact
    CustomCampaign.where(external_id: ids).delete_all if ids.any?
  end

  private

  def build_payload
    records = source_records
    return [] unless records

    records.map do |record|
      next unless record.is_a?(Hash)

      {
        external_id: record["id"],
        description: record["description"],
        date: parse_iso_time(record["date"]),
        payload: record["payload"],
        voucher: record["voucher"],
        targeting: record["targeting"],
        limit_value: record["limit"]&.to_s,
        media: record["media"],
        status: record["status"],
        risk_level: record["riskLevel"],
        post_on_status: record["postOnStatus"],
        reference: record["$ref"],
        raw_data: record,
        created_at: parse_iso_time(record["createdAt"])
      }
    end.compact
  end

  def source_records
    return @source_records if defined?(@source_records)

    file_path = Rails.root.join("..", "..", "json_files", "custom-campaigns.json")
    @source_records =
      if File.exist?(file_path)
        JSON.parse(File.binread(file_path))
      else
        warn "custom-campaigns.json not found, skipping custom_campaigns import"
        nil
      end
  rescue JSON::ParserError => e
    warn "Failed to parse custom-campaigns.json: #{e.message}"
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

