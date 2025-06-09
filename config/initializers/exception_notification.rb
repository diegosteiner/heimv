# frozen_string_literal: true

if defined?(ExceptionNotification)
  Rails.application.config.middleware.use(
    ExceptionNotification::Rails, email: {
      sender_address: ENV.fetch('MAIL_FROM', nil),
      email_prefix: "[#{ENV.fetch('APP_HOST', nil)}] ",
      exception_recipients: ENV.fetch('EXCEPTION_RECIPIENTS', 'info@heimv.ch').split(',')
    }
  )
end
