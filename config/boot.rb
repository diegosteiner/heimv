# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

if ENV['TRACE_OBJECT_ALLICATIONS']
  require 'objspace'
  ObjectSpace.trace_object_allocations_start
end

require 'bundler/setup' # Set up gems listed in the Gemfile.
# require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
