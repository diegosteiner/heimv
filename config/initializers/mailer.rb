# frozen_string_literal: true

if Rails.env.test?
  ActionMailer::Base.delivery_method = :test
  Pony.options = {
    from: ENV.fetch('MAIL_FROM', 'test@heimv.local'),
    via: :test,
    charset: 'UTF-8'
  }
else
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = SmtpConfig.from_string(ENV.fetch('SMTP_URL'))
  Pony.options = {
    from: ENV.fetch('MAIL_FROM', 'test@heimv.local'),
    via: :smtp,
    via_options: SmtpConfig.from_string(ENV.fetch('SMTP_URL')),
    charset: 'UTF-8'
  }
end
