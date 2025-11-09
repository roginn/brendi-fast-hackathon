class AggregatedMetric < ApplicationRecord
  attribute :result, :json, default: {}

  validates :name, presence: true
  validates :sql_query, presence: true
  validates :result, presence: true

  def result_json(pretty: false)
    data = result.presence || {}
    pretty ? JSON.pretty_generate(data) : JSON.generate(data)
  end

  def result_hash
    case result
    when Hash
      result.deep_symbolize_keys
    else
      result
    end
  end

  def self.coerce_result(value)
    case value
    when String
      JSON.parse(value)
    when nil
      {}
    else
      value
    end
  rescue JSON::ParserError => e
    raise ArgumentError, "Invalid JSON for AggregatedMetric#result: #{e.message}"
  end
end

