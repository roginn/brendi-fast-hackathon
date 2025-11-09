RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"] || ENV["OPEN_AI_API_KEY"]
  config.use_new_acts_as = true

  # Use GPT-5 for consultant workflows by default.
  config.default_model = "gpt-5"
end

