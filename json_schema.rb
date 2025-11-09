#!/usr/bin/env ruby

require 'json'
require 'set'

class JsonSchemaBuilder
  TYPE_MAP = {
    NilClass => 'null',
    TrueClass => 'boolean',
    FalseClass => 'boolean',
    Integer => 'integer',
    Float => 'number',
    String => 'string'
  }.freeze

  def initialize
    @schemas = {}
    @occurrences = Hash.new(0)
    @record_count = 0
  end

  def build_from_array(array)
    array.each do |item|
      unless item.is_a?(Hash)
        warn "Skipping non-object element: #{item.inspect}"
        next
      end

      @record_count += 1
      item.each do |key, value|
        @occurrences[key] += 1
        @schemas[key] = merge_schema(@schemas[key], schema_for(value))
      end
    end

    {
      'total_records' => @record_count,
      'schema' => serializable_schema
    }
  end

  private

  def schema_for(value)
    case value
    when Hash
      {
        types: Set['object'],
        properties: value.transform_values { |nested| schema_for(nested) }
      }
    when Array
      items_schema = nil
      value.each do |element|
        element_schema = schema_for(element)
        items_schema = merge_schema(items_schema, element_schema)
      end
      items_schema ||= { types: Set.new }
      {
        types: Set['array'],
        items: items_schema[:types].empty? ? nil : items_schema
      }
    else
      { types: Set[type_for(value)] }
    end
  end

  def type_for(value)
    TYPE_MAP.fetch(value.class) { 'string' }
  end

  def merge_schema(existing, incoming)
    return deep_dup(incoming) unless existing
    return deep_dup(existing) unless incoming

    merged = {
      types: existing[:types] | incoming[:types]
    }

    merge_object_properties!(merged, existing, incoming)
    merge_array_items!(merged, existing, incoming)

    merged
  end

  def merge_object_properties!(target, schema_a, schema_b)
    props_a = schema_a[:properties] || {}
    props_b = schema_b[:properties] || {}
    return if props_a.empty? && props_b.empty?

    target[:properties] = {}
    (props_a.keys | props_b.keys).each do |key|
      target[:properties][key] = merge_schema(props_a[key], props_b[key])
    end
  end

  def merge_array_items!(target, schema_a, schema_b)
    items_a = schema_a[:items]
    items_b = schema_b[:items]
    return unless items_a || items_b

    target[:items] = merge_schema(items_a, items_b)
  end

  def deep_dup(schema)
    return nil unless schema

    duplicated = { types: schema[:types].dup }
    duplicated[:properties] = schema[:properties]&.transform_values { |value| deep_dup(value) }
    duplicated[:items] = deep_dup(schema[:items]) if schema.key?(:items)
    duplicated
  end

  def serializable_schema
    @schemas.keys.sort.each_with_object({}) do |key, acc|
      schema = @schemas[key]
      serializable = {
        'types' => schema[:types].to_a.sort
      }

      if schema[:properties] && !schema[:properties].empty?
        serializable['properties'] = schema[:properties].transform_values do |nested|
          schema_to_hash(nested)
        end
      end

      serializable['items'] = schema_to_hash(schema[:items]) if schema[:items]
      serializable['present_in'] = @occurrences[key]

      presence_ratio = if @record_count.positive?
                         (@occurrences[key].to_f / @record_count) * 100
                       else
                         0.0
                       end
      serializable['presence_pct'] = presence_ratio.round(2)

      acc[key] = serializable
    end
  end

  def schema_to_hash(schema)
    return nil unless schema

    result = { 'types' => schema[:types].to_a.sort }
    if schema[:properties] && !schema[:properties].empty?
      result['properties'] = schema[:properties].transform_values { |nested| schema_to_hash(nested) }
    end
    result['items'] = schema_to_hash(schema[:items]) if schema[:items]
    result
  end
end

def usage_and_exit
  warn 'Usage: ruby json_schema.rb path/to/file.json'
  exit 1
end

def read_json_file(path)
  content = File.open(path, 'rb', &:read)
  content.force_encoding('UTF-8')
  content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
end

def parse_json_array(contents)
  JSON.parse(contents)
rescue JSON::ParserError => e
  starts_with_array = contents.match?(/\A\s*\[/)
  ends_with_array = contents.match?(/\]\s*\z/)

  if starts_with_array && !ends_with_array
    begin
      contents << "\n]"
      JSON.parse(contents)
    rescue JSON::ParserError
      raise e
    end
  else
    raise e
  end
end

usage_and_exit if ARGV.empty?

input_path = ARGV.first
usage_and_exit unless File.exist?(input_path)

file_contents = read_json_file(input_path)

begin
  parsed = parse_json_array(file_contents)
rescue JSON::ParserError => e
  warn "Failed to parse JSON: #{e.message}"
  exit 1
end

unless parsed.is_a?(Array)
  if parsed.is_a?(Hash)
    parsed = [parsed]
  else
    warn 'Top-level JSON value must be an array of objects or a single object.'
    exit 1
  end
end

builder = JsonSchemaBuilder.new
schema = builder.build_from_array(parsed)
puts JSON.pretty_generate(schema)

