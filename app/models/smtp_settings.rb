# frozen_string_literal: true

class SmtpSettings < Settings
  attribute :address, :string
  attribute :user_name, :string
  attribute :password, :string
  attribute :port, :integer, default: 25
  attribute :ssl, :boolean, default: false
  attribute :tls, :boolean, default: false
  attribute :authentication, :string
  attribute :enable_starttls_auto, :boolean, default: true
  attribute :open_timeout, :integer, default: 5
  attribute :read_timeout, :integer, default: 5

  def self.from_env
    from_json(ENV.fetch('SMTP_SETTINGS'))
  end

  def self.from_json(value)
    Settings::Type.new(SmtpSettings).cast_value(value)
  end

  def to_h
    super.symbolize_keys
  end
end
