# frozen_string_literal: true

require 'sidekiq/api'

class HealthService
  def cache_ok?
    Rails.cache.stats.present?
  rescue StandardError => e
    Rails.logger.error(e)
    false
  end

  def jobs_ok?
    !Sidekiq::Stats.new.queues.nil?
  rescue StandardError => e
    Rails.logger.error(e)
    false
  end

  def db_ok?
    ApplicationRecord.connection
    ApplicationRecord.connected?
  rescue StandardError => e
    Rails.logger.error(e)
    false
  end

  def to_h
    {
      cache: cache_ok?,
      jobs: jobs_ok?,
      db: db_ok?
    }
  end

  def ok?
    to_h.values.all?
  end
end
