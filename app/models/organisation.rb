# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  account_address           :string
#  address                   :text
#  bcc                       :string
#  booking_flow_type         :string
#  booking_ref_template      :string           default("")
#  cors_origins              :text
#  country_code              :string           default("CH"), not null
#  creditor_address          :text
#  currency                  :string           default("CHF")
#  default_payment_info_type :string
#  email                     :string
#  esr_beneficiary_account   :string
#  esr_ref_prefix            :string
#  homes_limit               :integer
#  iban                      :string
#  invoice_ref_template      :string           default("")
#  locale                    :string
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  nickname_label_i18n       :jsonb
#  notifications_enabled     :boolean          default(TRUE)
#  representative_address    :string
#  settings                  :jsonb
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
  extend Mobility

  has_many :bookings, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :homes, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :tenants, -> { ordered }, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :rich_text_templates, inverse_of: :organisation, dependent: :destroy
  has_many :operators, inverse_of: :organisation, dependent: :destroy
  has_many :operator_responsibilities, inverse_of: :organisation, dependent: :destroy
  has_many :booking_agents, inverse_of: :organisation, dependent: :destroy
  has_many :booking_categories, -> { ordered }, inverse_of: :organisation, dependent: :destroy
  has_many :booking_validations, inverse_of: :organisation, dependent: :destroy
  has_many :designated_documents, dependent: :destroy, inverse_of: :organisation
  has_many :data_digest_templates, dependent: :destroy, inverse_of: :organisation
  has_many :booking_questions, dependent: :destroy, inverse_of: :organisation
  has_many :payments, through: :bookings
  has_many :invoices, through: :bookings
  has_many :notifications, through: :bookings
  has_many :organisation_users, dependent: :destroy
  has_many :occupiables, dependent: :destroy
  has_many :users, through: :organisation_users
  has_many :tarifs, dependent: :destroy, inverse_of: :organisation
  has_many :plan_b_backups, dependent: :destroy, inverse_of: :organisation
  has_many :vat_categories, dependent: :destroy, inverse_of: :organisation
  has_many :key_sequences, dependent: :destroy, inverse_of: :organisation

  has_one_attached :logo
  has_one_attached :contract_signature

  locale_enum default: I18n.locale
  attr_writer :booking_flow_class

  translates :nickname_label, column_suffix: '_i18n', locale_accessors: true

  scope :ordered, -> { order(name: :ASC) }

  validates :booking_flow_type, presence: true
  validates :currency, :country_code, presence: true
  validates :name, :email, presence: true
  validates :slug, uniqueness: true, allow_blank: true
  validates :logo, :contract_signature, content_type: { in: ['image/png', 'image/jpeg'] }
  validates :locale, presence: true
  validate do
    errors.add(:settings, :invalid) unless settings.valid?
    errors.add(:smtp_settings, :invalid) unless smtp_settings.nil? || smtp_settings.valid?
    errors.add(:accounting_settings, :invalid) unless accounting_settings.nil? || accounting_settings.valid?
    errors.add(:creditor_address, :invalid) if creditor_address&.lines&.count&.> 3
    errors.add(:account_address, :invalid) if account_address&.lines&.count&.> 3
    errors.add(:iban, :invalid) if iban.present? && !iban.valid?
  end

  attribute :booking_flow_type, default: -> { BookingFlows::Default.to_s }
  attribute :settings, Settings::Type.new(OrganisationSettings), default: -> { OrganisationSettings.new }
  attribute :accounting_settings, Settings::Type.new(AccountingSettings), default: -> { AccountingSettings.new }
  attribute :smtp_settings, Settings::Type.new(SmtpSettings)
  attribute :iban, IBAN::Type.new
  attribute :tenant_ref_template, default: -> { RefBuilders::Tenant::DEFAULT_TEMPLATE }
  attribute :booking_ref_template, default: -> { RefBuilders::Booking::DEFAULT_TEMPLATE }
  attribute :invoice_ref_template, default: -> { RefBuilders::Invoice::DEFAULT_TEMPLATE }
  attribute :invoice_payment_ref_template, default: -> { RefBuilders::InvoicePayment::DEFAULT_TEMPLATE }

  def booking_flow_class
    @booking_flow_class ||= BookingFlows.const_get(booking_flow_type)
  end

  def slug=(value)
    self[:slug] = value.presence
  end

  def address_lines
    @address_lines ||= address&.lines&.map(&:strip)&.compact_blank || []
  end

  def to_s
    name
  end

  def to_param
    slug
  end

  def locale
    super || I18n.locale || I18n.default_locale
  end

  def locales
    locales = Organisation.locales.keys.map(&:to_s)
    locales &= settings.locales if settings.locales.present?
    locales
  end

  def show_nickname?
    nickname_label_i18n.present?
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def initialize_copy(origin)
    super
    self.rich_text_templates = origin.rich_text_templates.map(&:dup)
    self.booking_agents = origin.booking_agents.map(&:dup)
    self.booking_categories = origin.booking_categories.map(&:dup)
    self.tarifs = origin.tarifs.map(&:dup)
    self.booking_questions = origin.booking_questions.map(&:dup)
    self.designated_documents = origin.designated_documents.map(&:dup)
    self.data_digest_templates = origin.data_digest_templates.map(&:dup)

    return if origin.logo.blank?

    file.attach(io: StringIO.new(origin.logo.download),
                filename: origin.logo.filename,
                content_type: origin.logo.content_type)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
end
