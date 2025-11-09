#!/usr/bin/env ruby

require 'json'
require 'set'

def usage_and_exit
  warn 'Usage: ruby json_examples.rb path/to/data.json path/to/schema.json [output.json]'
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

usage_and_exit if ARGV.length < 2

data_path, schema_path, output_path = ARGV

usage_and_exit unless File.exist?(data_path) && File.exist?(schema_path)

begin
  data = parse_json_array(read_json_file(data_path))
rescue JSON::ParserError => e
  warn "Failed to parse data JSON: #{e.message}"
  exit 1
end

begin
  schema = JSON.parse(read_json_file(schema_path))
rescue JSON::ParserError => e
  warn "Failed to parse schema JSON: #{e.message}"
  exit 1
end

unless data.is_a?(Array)
  if data.is_a?(Hash)
    data = [data]
  else
    warn 'Data file must contain a JSON array of objects or a single object.'
    exit 1
  end
end

schema_hash = schema['schema']

unless schema_hash.is_a?(Hash)
  warn 'Schema file must be produced by json_schema.rb and contain a top-level "schema" hash.'
  exit 1
end

required_keys = schema_hash.keys.to_set

if required_keys.empty?
  warn 'Schema does not define any keys.'
  exit 1
end

records = data.each_with_index.map do |item, index|
  unless item.is_a?(Hash)
    warn "Skipping non-object element at index #{index}."
    next nil
  end
  { index: index, object: item, keys: item.keys.to_set }
end.compact

if records.empty?
  warn 'No valid objects found in the data file.'
  exit 1
end

min_samples = [3, records.length].min
random = Random.new
selected = records.sample(min_samples, random: random)
selected_indexes = selected.map { |entry| entry[:index] }.to_set
covered_keys = selected.reduce(Set.new) { |acc, entry| acc | entry[:keys] }

if covered_keys != required_keys
  records.each do |entry|
    next if selected_indexes.include?(entry[:index])

    missing = required_keys - covered_keys
    next if (entry[:keys] & missing).empty?

    selected << entry
    selected_indexes << entry[:index]
    covered_keys |= entry[:keys]
    break if covered_keys == required_keys
  end
end

unless covered_keys == required_keys
  warn 'Unable to cover all schema keys with available data.'
  exit 1
end

selected.sort_by! { |entry| entry[:index] }
output_array = selected.map { |entry| entry[:object] }
json_output = JSON.pretty_generate(output_array)

if output_path
  File.write(output_path, json_output)
else
  puts json_output
end

