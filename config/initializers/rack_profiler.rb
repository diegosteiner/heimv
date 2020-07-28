# frozen_string_literal: true

Rack::MiniProfiler.config.enable_advanced_debugging_tools = true

require 'objspace'
ObjectSpace.trace_object_allocations_start
