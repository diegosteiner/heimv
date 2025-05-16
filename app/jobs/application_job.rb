# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  after_discard do |job, exception|
    Rails.error.report(exception)
    ExceptionNotifier.notify_exception(exception, data: job.serialize) if defined?(ExceptionNotifier)
    raise exception
  end
end
