# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.configure do
  redis_url = ENV.slice('REDIS_TLS_URL', 'REDIS_URL').values.compact.first

  if redis_url.present?
    config.cache_store = :redis_cache_store, { url: redis_url,
                                               namespace: :heimv_cache,
                                               connect_timeout: 30, # Defaults to 20 seconds
                                               read_timeout: 0.2, # Defaults to 1 second
                                               write_timeout: 0.2, # Defaults to 1 second
                                               reconnect_attempts: 1 } # ,   # Defaults to 0

  end
end
