# frozen_string_literal: true

class SmtpSettings
  include StoreModel::Model

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
    from_value(ENV.fetch('SMTP_SETTINGS'))
  end

  def to_h
    attributes.symbolize_keys
  end
end
