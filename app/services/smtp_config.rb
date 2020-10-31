# frozen_string_literal: true

class SmtpConfig
  def self.from_string(value)
    return from_url(value) if value.starts_with?('smtp://')

    from_json(value)
  end

  def self.from_json(value)
    {
      address: nil,
      user_name: nil,
      password: nil,
      port: nil,
      method: :smtp
    }.merge(JSON.parse(value, symbolize_names: true))
  end

  def self.from_url(value)
    URI(value).instance_eval do
      options = URI.decode_www_form(query || '').to_h
      {
        address: host,
        user_name: user,
        password: password,
        port: port,
        method: scheme&.to_sym
      }.merge(options).compact.symbolize_keys
    end
  end

  def self.from_env
    from_string(ENV.fetch('SMTP_URL'))
  end
end

module URI
  class SMTP < Generic
    DEFAULT_PORT = 25
  end
  @@schemes['SMTP'] = SMTP
end
