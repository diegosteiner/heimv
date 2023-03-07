# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  bcc                       :string
#  booking_flow_type         :string
#  creditor_address          :text
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
#  notifications_enabled     :boolean          default(TRUE)
#  qr_iban                   :string
#  ref_template              :string           default("%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s")
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
  has_many :bookings, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :homes, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :tenants, -> { ordered }, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :rich_text_templates, inverse_of: :organisation, dependent: :destroy
  has_many :operators, inverse_of: :organisation, dependent: :destroy
  has_many :operator_responsibilities, inverse_of: :organisation, dependent: :destroy
  has_many :booking_agents, inverse_of: :organisation, dependent: :destroy
  has_many :booking_categories, -> { ordered }, inverse_of: :organisation, dependent: :destroy
  has_many :designated_documents, dependent: :destroy, inverse_of: :organisation
  has_many :data_digest_templates, dependent: :destroy, inverse_of: :organisation
  has_many :bookable_extras, dependent: :destroy
  has_many :payments, through: :bookings
  has_many :invoices, through: :bookings
  has_many :organisation_users, dependent: :destroy
  has_many :occupiables, dependent: :destroy
  has_many :users, through: :organisation_users
  has_many :tarifs, dependent: :destroy, inverse_of: :organisation

  has_one_attached :logo
  has_one_attached :contract_signature

  locale_enum default: I18n.locale

  validates :booking_flow_type, presence: true
  validates :currency, :invoice_ref_strategy_type, presence: true
  validates :name, :email, presence: true
  validates :slug, uniqueness: true, allow_blank: true
  validates :logo, :contract_signature, content_type: { in: ['image/png', 'image/jpeg'] }
  validates :locale, presence: true
  validate -> { errors.add(:settings, :invalid) unless settings.valid? }
  validate -> { errors.add(:smtp_settings, :invalid) unless smtp_settings.nil? || smtp_settings.valid? }

  attribute :booking_flow_type, default: -> { BookingFlows::Default.to_s }
  attribute :settings, Settings::Type.new(OrganisationSettings), default: -> { OrganisationSettings.new }
  attribute :smtp_settings, Settings::Type.new(SmtpSettings)

  def booking_flow_class
    @booking_flow_class ||= BookingFlows.const_get(booking_flow_type)
  end

  def country_code
    'CH'
  end

  def invoice_ref_strategy
    @invoice_ref_strategy ||= RefStrategies.const_get(invoice_ref_strategy_type).new
  end

  def slug=(value)
    self[:slug] = value.presence
  end

  def address_lines
    @address_lines ||= address.lines.map(&:strip).compact_blank.presence || []
  end

  def creditor_address_lines
    return address_lines if creditor_address.blank?

    @creditor_address_lines ||= creditor_address.lines.map(&:strip).compact_blank.presence
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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def initialize_copy(origin)
    super
    self.rich_text_templates = origin.rich_text_templates.map(&:dup)
    self.booking_agents = origin.booking_agents.map(&:dup)
    self.booking_categories = origin.booking_categories.map(&:dup)
    self.tarifs = origin.tarifs.map(&:dup)
    self.bookable_extras = origin.bookable_extras.map(&:dup)
    self.designated_documents = origin.designated_documents.map(&:dup)
    self.data_digest_templates = origin.data_digest_templates.map(&:dup)

    return if origin.logo.blank?

    file.attach(io: StringIO.new(origin.logo.download),
                filename: origin.logo.filename,
                content_type: origin.logo.content_type)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
end
