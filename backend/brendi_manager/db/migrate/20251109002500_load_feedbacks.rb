# frozen_string_literal: true

require "json"
require "time"

class LoadFeedbacks < ActiveRecord::Migration[8.1]
  class Feedback < ActiveRecord::Base
    self.table_name = "feedbacks"
  end

  def up
    return unless table_exists?(:feedbacks)

    payload = build_payload
    return if payload.empty?

    Feedback.insert_all(payload)
  end

  def down
    ids = source_records.map { |record| record["id"] }.compact
    Feedback.where(external_id: ids).delete_all if ids.any?
  end

  private

  def build_payload
    records = source_records
    return [] unless records

    records.map do |record|
      next unless record.is_a?(Hash)

      {
        external_id: record["id"],
        store_id: record["store_id"],
        store_consumer_id: record["store_consumer_id"],
        order_id: record["order_id"],
        category: record["category"],
        rating: record["rating"],
        rated_response: record["rated_response"],
        raw_data: record,
        created_at: parse_iso_time(record["created_at"]),
        updated_at: parse_iso_time(record["updated_at"])
      }
    end.compact
  end

  def source_records
    return @source_records if defined?(@source_records)

    file_path = Rails.root.join("..", "..", "json_files", "feedbacks.json")
    @source_records =
      if File.exist?(file_path)
        JSON.parse(File.binread(file_path))
      else
        warn "feedbacks.json not found, skipping feedbacks import"
        nil
      end
  rescue JSON::ParserError => e
    warn "Failed to parse feedbacks.json: #{e.message}"
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

