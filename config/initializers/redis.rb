# frozen_string_literal: true

# See https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-ruby

# rubocop:disable Style/GlobalVars
$redis = Redis.new(url: ENV.fetch('REDIS_URL', nil), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
# rubocop:enable Style/GlobalVars
