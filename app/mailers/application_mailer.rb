# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  def self.delivery_method_settings=(delivery_method_settings)
    raise 'MAILER_URL is invalid' unless delivery_method_settings.valid?

    @delivery_method_settings = delivery_method_settings

    ActionMailer::Base.delivery_method = delivery_method_settings.delivery_method
    ActionMailer::Base.try(delivery_method_settings.settings_method_name, delivery_method_settings.to_h)

    default from: -> { delivery_method_settings.fetch(:from, 'test@heimv.ch') },
            bcc: -> { delivery_method_settings[:bcc] }
  end

  self.delivery_method_settings = DeliveryMethodSettings.new(ENV['MAILER_URL']) if delivery_method.nil?
  layout 'mailer'
  default from: -> { 'test@heimv.ch' }
end
