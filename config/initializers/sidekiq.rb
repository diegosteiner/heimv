# frozen_string_literal: true

require Rails.root.join('config/initializers/redis')

redis_conn = proc {
  $redis
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 12, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 12, &redis_conn)
end
