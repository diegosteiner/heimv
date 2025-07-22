# frozen_string_literal: true

class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPFatalError, Net::SMTPAuthenticationError, Net::ReadTimeout, ActiveJob::DeserializationError,
           wait: 30.seconds, attempts: 5

  after_discard do |job, exception|
    Rails.error.report(exception)
    ExceptionNotifier.notify_exception(exception, data: job.serialize) if defined?(ExceptionNotifier)
    raise exception
  end
end
