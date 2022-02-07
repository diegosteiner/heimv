# frozen_string_literal: true

require_relative Rails.root.join('app/services/smtp_settings.rb')

if Rails.env.test?
  ActionMailer::Base.delivery_method = :test
  Pony.options = {
    from: ENV.fetch('MAIL_FROM', 'test@heimv.local'),
    via: :test,
    charset: 'UTF-8'
  }
else
  smtp_settings = SmtpSettings.from_env
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = smtp_settings
  Pony.options = {
    from: smtp_settings[:from] || ENV['MAIL_FROM'] || 'test@heimv.local',
    via: :smtp,
    via_options: smtp_settings,
    charset: 'UTF-8'
  }
end
