# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  bcc                       :string
#  booking_ref_strategy_type :string
#  booking_strategy_type     :string
#  currency                  :string           default("CHF")
#  email                     :string
#  esr_participant_nr        :string
#  iban                      :string
#  invoice_ref_strategy_type :string
#  locale                    :string           default("de")
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  notification_footer       :text
#  notifications_enabled     :boolean          default(TRUE)
#  payment_deadline          :integer          default(30), not null
#  representative_address    :string
#  slug                      :string
#  smtp_url                  :string
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
  has_many :tenants, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :markdown_templates, inverse_of: :organisation, dependent: :destroy
  has_many :payments, through: :bookings
  has_many :invoices, through: :bookings
  has_one_attached :logo
  has_one_attached :contract_signature
  has_one_attached :terms_pdf
  has_one_attached :privacy_statement_pdf

  validates :booking_strategy_type, presence: true
  validates :booking_ref_strategy_type, presence: true
  validates :invoice_ref_strategy_type, presence: true
  validates :name, :address, :email, presence: true
  validates :slug, uniqueness: true, allow_nil: true

  def booking_strategy
    @booking_strategy ||= BookingStrategies.const_get(booking_strategy_type).new
  end

  def booking_ref_strategy
    @booking_ref_strategy ||= RefStrategies.const_get(booking_ref_strategy_type).new
  end

  def invoice_ref_strategy
    @invoice_ref_strategy ||= RefStrategies.const_get(invoice_ref_strategy_type).new
  end

  def slug
    super.presence
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

  def missing_markdown_templates(locales = I18n.available_locales)
    locale_keys = booking_strategy.markdown_template_keys.flat_map do |key|
      locales.map { |locale| { locale: locale, key: key } }
    end
    locale_keys.reject { |locale_key| markdown_templates.where(locale_key).exists? }
  end
end
