module AggregatedMetrics
  class MetricExecutor
    class InvalidQueryError < StandardError; end

    READ_ONLY_SQL_REGEX = /\ASELECT\b/i

    def initialize(name:, sql_query:)
      @name = name
      @sql_query = sql_query.to_s
    end

    def call
      ensure_read_only!

      result_set = ActiveRecord::Base.connection.exec_query(sql_query)
      AggregatedMetric.create!(
        name: name,
        sql_query: sql_query,
        result: format_result(result_set)
      )
    end

    private

    attr_reader :name, :sql_query

    def ensure_read_only!
      return if READ_ONLY_SQL_REGEX.match?(sql_query.strip)

      raise InvalidQueryError, "Only read-only SELECT statements are allowed"
    end

    def format_result(result_set)
      {
        columns: result_set.columns,
        rows: result_set.to_a,
        row_count: result_set.rows.size
      }
    end
  end
end

