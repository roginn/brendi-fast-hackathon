# frozen_string_literal: true

require "json"
require "time"
require "date"

class LoadMenuEventsLast30Days < ActiveRecord::Migration[8.1]
  class MenuEvent < ActiveRecord::Base
    self.table_name = "menu_events_last_30_days"
  end

  def up
    return unless table_exists?(:menu_events_last_30_days)

    payload = build_payload
    return if payload.empty?

    MenuEvent.insert_all(payload)
  end

  def down
    ids = source_records.map { |record| record["id"] }.compact
    MenuEvent.where(external_id: ids).delete_all if ids.any?
  end

  private

  def build_payload
    records = source_records
    return [] unless records

    records.map do |record|
      next unless record.is_a?(Hash)

      {
        external_id: record["id"],
        created_at: parse_datetime(record["created_at"]),
        event_type: record["event_type"],
        device_type: record["device_type"],
        platform: record["platform"],
        referrer: record["referrer"],
        session_id: record["session_id"],
        store_id: record["store_id"],
        event_timestamp: parse_datetime(record["timestamp"]),
        metadata: parse_metadata(record["metadata"]),
        raw_data: record
      }
    end.compact
  end

  def source_records
    return @source_records if defined?(@source_records)

    file_path = Rails.root.join("..", "..", "json_files", "menu_events_last_30_days.json")
    @source_records =
      if File.exist?(file_path)
        JSON.parse(File.binread(file_path))
      else
        warn "menu_events_last_30_days.json not found, skipping menu events import"
        nil
      end
  rescue JSON::ParserError => e
    warn "Failed to parse menu_events_last_30_days.json: #{e.message}"
    nil
  end

  def parse_metadata(value)
    case value
    when String
      return nil if value.strip.empty?

      JSON.parse(value)
    when Hash, Array
      value
    else
      nil
    end
  rescue JSON::ParserError
    nil
  end

  def parse_datetime(value)
    case value
    when String
      parse_br_datetime(value)
    when Hash
      iso = value["iso"]
      iso ? Time.iso8601(iso) : nil
    else
      nil
    end
  rescue ArgumentError
    nil
  end

  def parse_br_datetime(value)
    return nil if value.nil?

    str = value.to_s.strip
    return nil if str.empty?

    begin
      DateTime.strptime(str, "%d/%m/%Y, %H:%M").to_time
    rescue ArgumentError
      DateTime.strptime(str, "%-d/%-m/%Y, %H:%M").to_time
    end
  rescue ArgumentError
    nil
  end
end

