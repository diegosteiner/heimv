# frozen_string_literal: true

Rails.application.config.to_prepare do
  if defined?(ExceptionNotification)
    Rails.application.config.middleware.use ExceptionNotification::Rack,
                                            email: {
                                              email_prefix: "[#{ENV['APP_HOST']}] ",
                                              exception_recipients: ENV.fetch('EXCEPTION_RECIPIENTS',
                                                                              'info@heimv.ch').split(',')
                                            }
  end
end
