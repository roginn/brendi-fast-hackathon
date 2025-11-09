module Consultant
  class MetricGenerator
    DEFAULT_METRIC_COUNT = 5
    MAX_FILE_BYTES = 40_000
    SCHEMA_PATHS = %w[
      db/schema.rb
    ].freeze
    INDICATORS_PATH = "prd/indicadores.md"

    def initialize(metric_count: DEFAULT_METRIC_COUNT, indicators_sections: nil)
      @metric_count = metric_count
      @indicators_sections = indicators_sections
    end

    def call
      binding.pry
      chat.ask(compiled_prompt)
    end

    private

    attr_reader :metric_count, :indicators_sections

    def chat
      @chat ||= RubyLLM
        .chat(model: "gpt-5")
        .with_instructions(system_prompt)
        .with_tool(AggregatedMetrics::MetricCreationTool.new)
    end

    def compiled_prompt
      <<~PROMPT
        ## Business context
        #{indicators_context}

        ## Database schemas
        #{schema_context}

        ## Migration summaries
        #{migration_context}

        ## Task
        You must propose up to #{metric_count} aggregated business metrics focused on actionable insights
        for the restaurant context. For each metric:
        - Choose a concise snake_case name.
        - Write a read-only SQL `SELECT` statement compatible with PostgreSQL.
        - Immediately call the tool `AggregatedMetrics::MetricCreationTool` with the metric name and SQL.
        - Ensure the SQL returns aggregated data and aliases columns clearly (e.g., `total_revenue`).
        - Provide filtering clauses only when necessary and document assumptions inside SQL comments.

        After registering all metrics via tool calls, respond with a short textual summary highlighting the new metrics and insights covered.
      PROMPT
    end

    def system_prompt
      <<~PROMPT
        You are a business consultant who specializes in hospitality analytics.
        Your role is to design aggregated metrics that drive strategic decisions for restaurants.
        You interact with a Ruby on Rails system that provides a tool named `AggregatedMetrics::MetricCreationTool`.
        Always use this tool to persist every metric you invent. Never fabricate execution results—rely on the tool.
        Prefer SQL that is easy to maintain, uses explicit column aliases, and handles NULL safety.
      PROMPT
    end

    def indicators_context
      content = read_file(INDICATORS_PATH)
      return "Indicators document not found." if content.blank?

      selected_content = if indicators_sections.present?
                           extract_sections(content, indicators_sections)
                         else
                           content
                         end

      <<~MARKDOWN
        ```markdown
        #{truncate(selected_content)}
        ```
      MARKDOWN
    end

    def schema_context
      contexts = SCHEMA_PATHS.filter_map do |relative_path|
        content = read_file(relative_path)
        next if content.blank?

        <<~MARKDOWN
          ### #{relative_path}
          ```ruby
          #{truncate(content)}
          ```
        MARKDOWN
      end

      contexts.presence || "Schema files not available."
    end

    def migration_context
      migration_paths = Dir.glob(Rails.root.join("db", "migrate", "*.rb")).sort.last(10)
      return "No migrations found." if migration_paths.empty?

      migration_paths.map do |path|
        relative = Pathname.new(path).relative_path_from(Rails.root)
        <<~MARKDOWN
          ### #{relative}
          ```ruby
          #{truncate(File.read(path))}
          ```
        MARKDOWN
      end.join("\n")
    end

    def read_file(relative_path)
      absolute = Rails.root.join(relative_path)
      return unless File.exist?(absolute)

      File.read(absolute)
    end

    def extract_sections(content, section_titles)
      current_title = nil
      buffer = +""
      content.each_line do |line|
        if line.start_with?("## ")
          current_title = line.delete_prefix("## ").strip
        end

        next unless section_titles.include?(current_title)

        buffer << line
      end
      buffer
    end

    def truncate(content)
      return content if content.bytesize <= MAX_FILE_BYTES

      "#{content.byteslice(0, MAX_FILE_BYTES)}\n# ... truncated ..."
    end
  end
end

