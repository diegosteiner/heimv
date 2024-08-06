# frozen_string_literal: true

class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPFatalError,
           Net::SMTPAuthenticationError,
           Net::ReadTimeout,
           ActiveJob::DeserializationError,
           Errno::ECONNREFUSED,
           wait: 30.seconds, attempts: 5
  # discard_on ActiveJob::DeserializationError
  sidekiq_options retry: 5
end
