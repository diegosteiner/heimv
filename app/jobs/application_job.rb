# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  after_discard do |job, exception|
    Rails.error.report(exception)
    ExceptionNotifier.notify_exception(exception, data: job.serialize)
    raise exception
  end
end
