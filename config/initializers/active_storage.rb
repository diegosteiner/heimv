aws_keys = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_BUCKET_NAME]
Rails.application.config.active_storage.service = :amazon if Rails.env.production? && (aws_keys - ENV.keys).empty?

s3_keys = %w[S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY S3_BUCKET_NAME S3_ENDPOINT]
Rails.application.config.active_storage.service = :s3 if Rails.env.production? && (s3_keys - ENV.keys).empty?
