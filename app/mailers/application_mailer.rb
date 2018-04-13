# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ActionMailer::Base.delivery_method.nil?
    SettingsProvider.mailer_settings.tap do |settings|
      Rails.logger.debug settings.inspect
      ActionMailer::Base.delivery_method = settings.fetch(:delivery_method)
      ActionMailer::Base.try(ActionMailer::Base.delivery_method.to_s + '_settings=', settings)
      # default from: settings.fetch(:from, 'no-reply@heimverwaltung.localhost')
    end
  end
  default from: Rails.application.secrets.mail_from
  layout 'mailer'
end
