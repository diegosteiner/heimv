# frozen_string_literal: true

s3_keys = %w[S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY S3_BUCKET_NAME S3_ENDPOINT]
Rails.application.config.active_storage.service = :s3 if Rails.env.production? && (s3_keys - ENV.keys).empty?
