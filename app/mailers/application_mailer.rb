# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ActionMailer::Base.delivery_method.nil?
    settings = SettingsProvider.mailer_settings
    ActionMailer::Base.delivery_method = settings.fetch(:delivery_method)
    ActionMailer::Base.try(ActionMailer::Base.delivery_method.to_s + '_settings=', settings)
    default from: settings.fetch(:from, 'no-reply@heimverwaltung.localhost')
  end
  layout 'mailer'
end
