# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  self.delivery_method_settings = DeliveryMethodSettings.new(ENV['MAILER_URL']) if delivery_method.nil?

  def self.deliver_method_settings=(delivery_method_settings)
    raise 'MAILER_URL is invalid' unless delivery_method_settings.valid?

    @delivery_method_settings = delivery_method_settings

    self.delivery_method = delivery_method_settings.delivery_method
    try(delivery_method_settings.settings_method_name, delivery_method_settings.to_h)

    default from: -> { delivery_method_settings.fetch(:from, 'test@heimv.ch') },
            bcc: -> { delivery_method_settings[:bcc] }
  end

  layout 'mailer'
  default from: -> { 'test@heimv.ch' }
end
