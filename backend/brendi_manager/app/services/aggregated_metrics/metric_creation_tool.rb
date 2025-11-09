module AggregatedMetrics
  class MetricCreationTool < RubyLLM::Tool
    description "Executes read-only SQL to persist aggregated business metrics."

    param :name,
          desc: "Short descriptive metric name (snake_case).",
          type: "string"
    param :sql_query,
          desc: "Read-only SQL query that returns aggregated data.",
          type: "string"

    def execute(name:, sql_query:)
      metric = MetricExecutor.new(name:, sql_query:).call

      {
        status: "ok",
        metric_id: metric.id,
        result: metric.result,
        created_at: metric.created_at.iso8601
      }
    rescue MetricExecutor::InvalidQueryError => e
      {
        status: "error",
        error: e.message
      }
    rescue ActiveRecord::ActiveRecordError => e
      {
        status: "error",
        error: "Database error: #{e.message}"
      }
    end
  end
end

