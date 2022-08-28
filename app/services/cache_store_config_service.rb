# frozen_string_literal: true

class CacheStoreConfigService
  def self.derive
    redis
  end

  def self.in_memory
    ActiveSupport::Cache::MemoryStore.new
  end

  def self.redis(redis_url = ENV.slice('REDIS_TLS_URL', 'REDIS_URL').values.compact.first)
    return if redis_url.blank?

    ActiveSupport::Cache::RedisCacheStore.new(url: redis_url, driver: :hiredis,
                                              namespace: :heimv_cache,
                                              connect_timeout: 30, # Defaults to 20 seconds
                                              read_timeout: 0.2, # Defaults to 1 second
                                              write_timeout: 0.2, # Defaults to 1 second
                                              reconnect_attempts: 1) # ,   # Defaults to 0
  end
end
