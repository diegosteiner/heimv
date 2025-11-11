# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                           :bigint           not null, primary key
#  account_address              :string
#  accounting_settings          :jsonb
#  address                      :text
#  bcc                          :string
#  booking_flow_type            :string
#  booking_ref_template         :string           default("%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_ref_alpha>s")
#  booking_state_settings       :jsonb
#  cors_origins                 :text
#  country_code                 :string           default("CH"), not null
#  creditor_address             :text
#  currency                     :string           default("CHF")
#  deadline_settings            :jsonb
#  default_payment_info_type    :string
#  email                        :string
#  esr_beneficiary_account      :string
#  esr_ref_prefix               :string
#  homes_limit                  :integer
#  iban                         :string
#  invoice_payment_ref_template :string           default("%<prefix>s%<tenant_sequence_number>06d%<sequence_year>04d%<sequence_number>05d")
#  invoice_ref_template         :string
#  locale                       :string
#  location                     :string
#  mail_from                    :string
#  name                         :string
#  nickname_label_i18n          :jsonb
#  notifications_enabled        :boolean          default(TRUE)
#  qr_bill_creditor_address     :jsonb
#  representative_address       :string
#  settings                     :jsonb
#  slug                         :string
#  smtp_settings                :jsonb
#  tenant_ref_template          :string
#  users_limit                  :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
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
  has_many :journal_entry_batches, through: :invoices
  has_many :notifications, through: :bookings
  has_many :organisation_users, dependent: :destroy
  has_many :occupiables, dependent: :destroy
  has_many :users, through: :organisation_users
  has_many :tarifs, dependent: :destroy, inverse_of: :organisation
  has_many :plan_b_backups, dependent: :destroy, inverse_of: :organisation
  has_many :vat_categories, dependent: :destroy, inverse_of: :organisation
  has_many :key_sequences, dependent: :destroy, inverse_of: :organisation
  has_many :oauth_tokens, dependent: :destroy, inverse_of: :organisation

  has_one_attached :logo
  has_one_attached :contract_signature

  locale_enum default: I18n.locale
  attr_writer :booking_flow_class

  translates :nickname_label, column_suffix: '_i18n', locale_accessors: true

  scope :ordered, -> { order(name: :ASC) }

  validates :booking_flow_type, presence: true
  validates :currency, :country_code, presence: true
  validates :country_code, inclusion: { in: ISO3166::Country.codes }
  validates :name, :email, presence: true
  validates :slug, uniqueness: true, allow_blank: true
  validates :logo, :contract_signature, content_type: { in: ['image/png', 'image/jpeg'] }
  validates :locale, presence: true
  validate do
    errors.add(:creditor_address, :invalid) if creditor_address&.lines&.count&.> 3
    errors.add(:account_address, :invalid) if account_address&.lines&.count&.> 3
    errors.add(:iban, :invalid) if iban.present? && !iban.valid?
  end

  attribute :booking_flow_type, default: -> { BookingFlows::Default.to_s }
  attribute :settings, OrganisationSettings.to_type, default: -> { OrganisationSettings.new }
  attribute :accounting_settings, AccountingSettings.to_type, default: -> { AccountingSettings.new }
  attribute :smtp_settings, SmtpSettings.to_type
  attribute :booking_state_settings, BookingStateSettings.to_type, default: -> { BookingStateSettings.new }
  attribute :deadline_settings, DeadlineSettings.to_type, default: -> { DeadlineSettings.new }
  attribute :iban, IBAN::Type.new
  attribute :tenant_ref_template, default: -> { RefBuilders::Tenant::DEFAULT_TEMPLATE }
  attribute :booking_ref_template, default: -> { RefBuilders::Booking::DEFAULT_TEMPLATE }
  attribute :invoice_ref_template, default: -> { RefBuilders::Invoice::DEFAULT_TEMPLATE }
  attribute :invoice_payment_ref_template, default: -> { RefBuilders::InvoicePayment::DEFAULT_TEMPLATE }
  attribute :qr_bill_creditor_address, Address.to_type, default: -> { Address.new }

  def booking_flow_class
    @booking_flow_class ||= BookingFlows.const_get(booking_flow_type)
  end

  def slug=(value)
    self[:slug] = value.presence
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
  def initialize_copy(original)
    super
    self.rich_text_templates = original.rich_text_templates.map(&:dup)
    self.booking_agents = original.booking_agents.map(&:dup)
    self.booking_categories = original.booking_categories.map(&:dup)
    self.tarifs = original.tarifs.map(&:dup)
    self.booking_questions = original.booking_questions.map(&:dup)
    self.designated_documents = original.designated_documents.map(&:dup)
    self.data_digest_templates = original.data_digest_templates.map(&:dup)

    return if original.logo.blank?

    file.attach(io: StringIO.new(original.logo.download),
                filename: original.logo.filename,
                content_type: original.logo.content_type)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
end
