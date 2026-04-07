# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  after_discard do |job, exception|
    Sentry.with_scope do |scope|
      scope.set_context('job', job.serialize)
      Sentry.capture_exception(exception)
    end

    Rails.error.report(exception)
    ExceptionNotifier.notify_exception(exception, data: job.serialize)
    raise exception
  end
end
