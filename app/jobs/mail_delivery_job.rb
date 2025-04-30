# frozen_string_literal: true

class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPFatalError, Net::SMTPAuthenticationError, Net::ReadTimeout, ActiveJob::DeserializationError,
           wait: 30.seconds, attempts: 5

  rescue_from(Exception) do |exception|
    ExceptionNotifier.notify_exception(exception) if defined?(ExceptionNotifier)
    Rails.error.report(exception)
    raise exception
  end
end
