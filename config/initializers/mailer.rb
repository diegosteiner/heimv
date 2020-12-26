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
  ActionMailer::Base.smtp_settings = SmtpSettings.from_env
  Pony.options = {
    from: ENV.fetch('MAIL_FROM', 'test@heimv.local'),
    via: :smtp,
    via_options: JSON.parse(ENV.fetch('SMTP_SETTINGS')),
    charset: 'UTF-8'
  }
end
