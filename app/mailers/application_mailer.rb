# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ActionMailer::Base.delivery_method.nil?
    delivery_method_settings = DeliveryMethodSettings.new(ENV['MAILER_URL'])
    ActionMailer::Base.delivery_method = delivery_method_settings.delivery_method
    ActionMailer::Base.try(delivery_method_settings.settings_method_name, delivery_method_settings.to_h)
  end

  layout 'mailer'
end
