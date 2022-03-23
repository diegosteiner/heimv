# frozen_string_literal: true

Rails.application.configure do
  # Use a different cache store in production.
  if ENV['REDIS_URL'].present?
    config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'],
                                               connect_timeout: 30, # Defaults to 20 seconds
                                               read_timeout: 0.2, # Defaults to 1 second
                                               write_timeout: 0.2, # Defaults to 1 second
                                               reconnect_attempts: 1 } # ,   # Defaults to 0

  elsif ENV['MEMCACHIER_SERVERS'].present?
    config.cache_store = :mem_cache_store, ENV['MEMCACHIER_SERVERS'],
                         { username: ENV['MEMCACHIER_USERNAME'],
                           password: ENV['MEMCACHIER_PASSWORD'],
                           failover: true,
                           socket_timeout: 1.5,
                           socket_failure_delay: 0.2,
                           down_retry_delay: 10,
                           pool_size: ENV.fetch('RAILS_MAX_THREADS', 5) }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end
end

Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
