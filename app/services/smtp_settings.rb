class SmtpSettings
  attr_reader :settings

  def url(value)
    uri = URI(value)
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
end

module URI
  class SMTP < Generic
    DEFAULT_PORT = 25
  end
  @@schemes['SMTP'] = SMTP
end
