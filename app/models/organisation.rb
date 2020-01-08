# == Schema Information
#
# Table name: organisations
#
#  id                              :bigint           not null, primary key
#  address                         :text
#  booking_ref_strategy_type       :string
#  booking_strategy_type           :string
#  contract_representative_address :string
#  currency                        :string           default("CHF")
#  delivery_method_settings_url    :string
#  email                           :string
#  esr_participant_nr              :string
#  iban                            :string
#  invoice_ref_strategy_type       :string
#  message_footer                  :text
#  name                            :string
#  payment_information             :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Organisation < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :homes, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :tenants, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :markdown_templates, inverse_of: :organisation, dependent: :destroy
  has_one_attached :logo
  has_one_attached :contract_signature
  has_one_attached :terms_pdf
  has_one_attached :privacy_statement_pdf

  validates :booking_strategy_type, presence: true
  validates :booking_ref_strategy_type, presence: true
  validates :invoice_ref_strategy_type, presence: true
  validates :name, :address, :esr_participant_nr, presence: true

  def booking_strategy
    @booking_strategy ||= Kernel.const_get(booking_strategy_type).new
  end

  def booking_ref_strategy
    RefStrategies.const_get(booking_ref_strategy_type).new
  end

  def invoice_ref_strategy
    RefStrategies.const_get(invoice_ref_strategy_type).new
  end

  def long_deadline
    8.days
  end

  def short_deadline
    3.days
  end

  def booking_window
    18.months
  end

  def contract_location
    'Zürich'
  end

  def to_s
    name
  end

  def self.current
    first
  end

  def missing_markdown_templates(locales = I18n.available_locales)
    locale_keys = booking_strategy.markdown_template_keys.flat_map do |key|
      locales.map { |locale| { locale: locale, key: key } }
    end
    locale_keys.reject { |locale_key| markdown_templates.where(locale_key).exists? }
  end

  def delivery_method_settings
    @delivery_method_settings ||= DeliveryMethodSettings.new(delivery_method_settings_url || ENV['MAILER_URL'])
  end
end
