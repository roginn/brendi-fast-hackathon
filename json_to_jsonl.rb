#!/usr/bin/env ruby
# frozen_string_literal: true
# json_to_jsonl.rb
#
# Usage:
#   ruby json_to_jsonl.rb input.json [output.jsonl]
#
# Notes:
# - Expects the input JSON's top-level to be an array.
# - Writes each array element as a compact JSON line.
# - For *very* large files, this loads the whole JSON into memory.
#   If that’s a problem, consider a streaming parser (e.g., the 'oj' gem).

require "json"

def usage!
  abort "Usage: #{File.basename($PROGRAM_NAME)} INPUT.json [OUTPUT.jsonl]"
end

usage! if ARGV.empty?

input_path  = ARGV[0]
usage! unless input_path && File.file?(input_path)

# Default output: input name with .jsonl extension
default_out = File.join(
  File.dirname(input_path),
  File.basename(input_path, File.extname(input_path)) + ".jsonl"
)
output_path = ARGV[1] || default_out

# Read and parse
raw = File.read(input_path, mode: "rb")
begin
  data = JSON.parse(raw)
rescue JSON::ParserError => e
  abort "Failed to parse JSON: #{e.message}"
end

unless data.is_a?(Array)
  abort "Top-level JSON must be an array, got: #{data.class}"
end

# Write JSONL
begin
  File.open(output_path, "wb") do |f|
    data.each do |elem|
      f.write(JSON.generate(elem))
      f.write("\n")
    end
  end
rescue Errno::EACCES => e
  abort "Cannot write to #{output_path}: #{e.message}"
end

puts "Wrote #{data.length} line(s) to #{output_path}"