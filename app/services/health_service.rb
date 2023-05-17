# frozen_string_literal: true

class HealthService
  def cache_ok?
    Rails.cache.redis.ping == 'PONG'
  rescue StandardError
    false
  end

  def db_ok?
    ApplicationRecord.establish_connection
    ApplicationRecord.connection
    ApplicationRecord.connected?
  rescue StandardError
    false
  end

  def to_h
    {
      cache: cache_ok?,
      db: db_ok?
    }
  end

  def ok?
    to_h.values.all?
  end
end
