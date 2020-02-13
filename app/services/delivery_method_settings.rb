class DeliveryMethodSettings
  delegate :fetch, :[], to: :to_h

  def initialize(settings_url)
    @settings_url = settings_url
  end

  def valid?
    ActionMailer::Base.delivery_methods.keys.include?(delivery_method) &&
      delivery_method_settings.keys.include?(:from) || @settings_url.blank?
  end

  def delivery_method_settings
    uri = URI(@settings_url)
    {
      address: uri.host,
      user_name: uri.user,
      password: uri.password,
      port: uri.port,
      method: uri.scheme&.to_sym
    }.merge(Hash[URI.decode_www_form(uri.query || '')]).compact.symbolize_keys
  rescue ArgumentError
    {}
  end
  alias to_h delivery_method_settings

  def delivery_method
    @delivery_method ||= delivery_method_settings[:method]
  end

  def settings_method_name
    delivery_method.to_s + '_settings='
  end
end

module URI
  class SMTP < Generic
    DEFAULT_PORT = 25
  end
  @@schemes['SMTP'] = SMTP

  class Test < Generic
    DEFAULT_PORT = 0
  end
  @@schemes['Test'] = Test
end
