class SmtpSettings
  attr_reader :settings

  def url(value)
    uri = URI(value.split('smtp:').last)
    {
      address: uri.host,
      user_name: uri.user,
      password: uri.password,
      port: uri.port || 25,
      method: uri.scheme&.to_sym
    }.merge(Hash[URI.decode_www_form(uri.query || '')]).compact.symbolize_keys
  end
end
