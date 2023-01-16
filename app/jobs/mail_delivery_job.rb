# frozen_string_literal: true

class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPFatalError, Net::SMTPAuthenticationError, Net::ReadTimeout, ActiveJob::DeserializationError

  # discard_on ActiveJob::DeserializationError
end
