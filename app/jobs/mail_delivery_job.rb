# frozen_string_literal: true

class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPFatalError, Net::SMTPAuthenticationError, Net::ReadTimeout, ActiveJob::DeserializationError,
           wait: 30.seconds, attempts: 5

  rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    ExceptionNotifier.notify_exception(exception, data: serialize) if defined?(ExceptionNotifier)
    raise exception
  end
end
