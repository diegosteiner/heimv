# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  rescue_from(Exception) do |exception|
    ExceptionNotifier.notify_exception(exception) if defined?(ExceptionNotifier)
    Rails.error.report(exception)
    raise exception
  end
end
