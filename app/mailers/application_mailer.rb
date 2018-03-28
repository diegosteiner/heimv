# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  ActionMailer::Base.smtp_settings = SettingsProvider.mailer_smtp_settings
  default from: SettingsProvider.mailer_settings.fetch(:from)
  layout 'mailer'
end
