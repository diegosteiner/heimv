# frozen_string_literal: true

class CacheStoreFactory
  def self.in_memory
    ActiveSupport::Cache::MemoryStore.new
  end

  def self.redis(redis_config)
    ActiveSupport::Cache::RedisCacheStore.new(redis: Redis.new(**redis_config),
                                              namespace: :heimv_cache,
                                              connect_timeout: 30, # Defaults to 20 seconds
                                              read_timeout: 0.2, # Defaults to 1 second
                                              write_timeout: 0.2, # Defaults to 1 second
                                              reconnect_attempts: 1) # ,   # Defaults to 0
  end
end
