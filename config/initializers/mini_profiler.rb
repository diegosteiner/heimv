# frozen_string_literal: true

Rack::MiniProfiler.config.enable_advanced_debugging_tools = ENV['DEBUG'].present?
