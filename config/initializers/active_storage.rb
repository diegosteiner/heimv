aws_keys = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_BUCKET_NAME]
Rails.application.config.active_storage.service = :amazon if Rails.env.production? && (aws_keys - ENV.keys).empty?
