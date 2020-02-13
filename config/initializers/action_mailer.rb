module ActionMailer
  class Base
    class << self
      def delivery_method_settings=(delivery_method_settings)
        raise 'MAILER_URL is invalid' unless delivery_method_settings.valid?

        @delivery_method_settings = delivery_method_settings

        self.delivery_method = delivery_method_settings.delivery_method
        try(delivery_method_settings.settings_method_name, delivery_method_settings.to_h)

        default from: -> { delivery_method_settings.fetch(:from, 'test@heimv.ch') },
                bcc: -> { delivery_method_settings[:bcc] }
      end

      attr_reader :delivery_method_settings
    end

    default from: -> { 'test@heimv.ch' }
  end
end

ActionMailer::Base.delivery_method_settings = DeliveryMethodSettings.new(ENV['MAILER_URL'])
