# frozen_string_literal: true

class SmtpSettings
  def self.from_json(value)
    from_h(JSON.parse(value, symbolize_names: true))
  end

  def self.from_h(value)
    {
      address: nil,
      user_name: nil,
      password: nil,
      port: nil,
      method: :smtp
    }.merge(value)
  end

  def self.from_env
    from_json(ENV.fetch('SMTP_SETTINGS'))
  end

  def self.from_h_or_default(value)
    value.present? && from_h(value) || from_env
  end
end
