ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'objspace'
ObjectSpace.trace_object_allocations_start

require 'bundler/setup' # Set up gems listed in the Gemfile.
#require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
