# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    ExceptionNotifier.notify_exception(exception, data: serialize) if defined?(ExceptionNotifier)
    raise exception
  end
end
