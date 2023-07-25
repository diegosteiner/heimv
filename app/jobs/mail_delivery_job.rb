# frozen_string_literal: true

class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPFatalError, Net::SMTPAuthenticationError, Net::ReadTimeout, ActiveJob::DeserializationError,
           wait: 30.seconds
  # discard_on ActiveJob::DeserializationError
  sidekiq_options retry: 5
end
