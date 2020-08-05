# frozen_string_literal: true

if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
                                          email: {

                                            sender_address: ENV['MAIL_FROM'],
                                            exception_recipients: Array.wrap(ENV['EXCEPTION_RECIPIENTS']),
                                            delivery_method: :smtp,
                                            smtp_settings: SmtpUrl.from_env
                                          }
end
