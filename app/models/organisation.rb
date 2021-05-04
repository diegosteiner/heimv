# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  bcc                       :string
#  booking_flow_type         :string
#  currency                  :string           default("CHF")
#  default_payment_info_type :string
#  email                     :string
#  esr_beneficiary_account   :string
#  esr_ref_prefix            :string
#  homes_limit               :integer
#  iban                      :string
#  invoice_ref_strategy_type :string
#  invoice_ref_template      :string           default("%<prefix>s%<home_id>03d%<tenant_id>06d%<invoice_id>07d")
#  locale                    :string           default("de")
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  notification_footer       :text
#  notifications_enabled     :boolean          default(TRUE)
#  payment_deadline          :integer          default(30), not null
#  ref_template              :string           default("%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s")
#  representative_address    :string
#  slug                      :string
#  smtp_settings             :jsonb
#  users_limit               :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_organisations_on_slug  (slug) UNIQUE
#

class Organisation < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :homes, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :tenants, -> { ordered }, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :rich_text_templates, inverse_of: :organisation, dependent: :destroy
  has_many :booking_agents, inverse_of: :organisation, dependent: :destroy
  has_many :booking_purposes, -> { ordered }, inverse_of: :organisation, dependent: :destroy
  has_many :payments, through: :bookings
  has_many :invoices, through: :bookings
  has_one_attached :logo
  has_one_attached :contract_signature
  has_one_attached :terms_pdf
  has_one_attached :privacy_statement_pdf

  validates :booking_flow_type, presence: true
  validates :invoice_ref_strategy_type, presence: true
  validates :name, :email, presence: true
  validates :slug, uniqueness: true, allow_nil: true
  validate do
    errors.add(:smtp_settings, :invalid) unless smtp_settings.is_a?(Hash) || smtp_settings.nil?
  end

  attribute :booking_flow_type, default: BookingFlows::Default.to_s

  def booking_flow_class
    @booking_flow_class ||= BookingFlows.const_get(booking_flow_type)
  end

  def invoice_ref_strategy
    @invoice_ref_strategy ||= RefStrategies.const_get(invoice_ref_strategy_type).new
  end

  def slug=(value)
    self[:slug] = value.presence
  end

  def address_lines
    @address_lines ||= address.lines.map(&:strip).reject(&:blank?).presence || []
  end

  def smtp_settings_json
    JSON.generate(smtp_settings)
  end

  def smtp_settings_json=(value)
    self.smtp_settings = JSON.parse(value)
  rescue JSON::ParserError
    errors.add(:smtp_settings_json, :invalid)
    smtp_settings
  end

  # TODO: extract to hash
  def long_deadline
    10.days
  end

  def short_deadline
    3.days
  end

  def payment_deadline
    30.days
  end

  def booking_window
    30.months
  end

  def to_s
    name
  end

  def mailer
    @mailer ||= OrganisationMailer.new(self)
  end

  def locale
    super || I18n.locale || I18n.default_locale
  end
end
