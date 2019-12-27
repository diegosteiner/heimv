class DeliveryMethodSettings
  def initialize(settings_url)
    @settings_url = settings_url

    return if settings_url.blank?

    @delivery_method, delivery_method_settings_url = settings_url&.split('://')
    @delivery_method_settings = extract_delivery_method_settings(delivery_method_settings_url)
  end

  def to_h
    @delivery_method_settings || {}
  end

  def delivery_method
    @delivery_method&.to_sym
  end

  def extract_delivery_method_settings(url_without_schema)
    uri = URI("//#{url_without_schema}")
    {
      address: uri.host,
      user_name: uri.user,
      password: uri.password,
      port: uri.port
    }.merge(Hash[URI.decode_www_form(uri.query)]).compact.symbolize_keys
    # rescue
  end

  def method
    delivery_method.to_s + '_settings='
  end
end
