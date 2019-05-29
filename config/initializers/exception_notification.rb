if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
                                          email: {
                                            # email_prefix: '[PREFIX] ',
                                            sender_address: ENV['MAIL_FROM'],
                                            exception_recipients: Array.wrap(ENV['EXCEPTION_RECIPIENTS'])
                                          }
end
