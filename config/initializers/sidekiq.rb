# frozen_string_literal: true

Sidekiq.default_configuration.redis = { url: ENV.fetch('REDIS_URL', nil),
                                        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
