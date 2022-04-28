# frozen_string_literal: true

Rails.application.config.to_prepare do
  if Rails.env.test?
    ActionMailer::Base.delivery_method = :test
  else
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = SmtpSettings.from_env.to_h
  end
end
