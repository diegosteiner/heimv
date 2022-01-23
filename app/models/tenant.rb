# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id                              :bigint           not null, primary key
#  additional_address              :string
#  allow_bookings_without_contract :boolean          default(FALSE)
#  birth_date                      :date
#  city                            :string
#  country_code                    :string           default("CH")
#  email                           :string
#  email_verified                  :boolean          default(FALSE)
#  first_name                      :string
#  iban                            :string
#  import_data                     :jsonb
#  last_name                       :string
#  nickname                        :string
#  phone                           :text
#  remarks                         :text
#  reservations_allowed            :boolean          default(TRUE)
#  search_cache                    :text             not null
#  street_address                  :string
#  zipcode                         :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  organisation_id                 :bigint           not null
#
# Indexes
#
#  index_tenants_on_email                      (email)
#  index_tenants_on_email_and_organisation_id  (email,organisation_id) UNIQUE
#  index_tenants_on_organisation_id            (organisation_id)
#  index_tenants_on_search_cache               (search_cache)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class Tenant < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error
  belongs_to :organisation

  validates :email, allow_nil: true, format: { with: Devise.email_regexp }, uniqueness: { scope: :organisation_id }
  validates :email, presence: true, on: :public_update
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, on: :public_update
  validates :street_address, length: { maximum: 255 }
  validates :birth_date, presence: true, on: :public_update
  validates :phone, presence: true, length: { minimum: 10, maximum: 255 }, on: :public_update

  scope :ordered, -> { order(last_name: :ASC, first_name: :ASC, id: :ASC) }

  before_validation do
    self.email = email&.strip.presence
  end

  before_save do
    self.search_cache = contact_lines.flatten.join('\n')
  end

  def name
    "#{first_name} #{last_name}"
  end

  def salutation_name
    I18n.t('tenant.salutation', name: [nickname, first_name].first(&:present?))
  end

  def address_lines
    [
      additional_address&.strip,
      street_address&.lines&.map(&:strip),
      "#{zipcode} #{city} #{country_code}"
    ].flatten.compact_blank
  end

  def full_address_lines
    [name, address_lines].flatten
  end

  def address
    full_address_lines.join("\n")
  end

  def contact_lines
    full_address_lines + [phone&.lines, email].flatten.compact_blank
  end

  def to_s
    "##{id} #{name}"
  end

  def complete?
    valid? &&
      [email, first_name, last_name, street_address, zipcode, city, country_code, birth_date, phone].all?(&:present?)
  end

  def to_liquid
    Public::TenantSerializer.render_as_hash(self).deep_stringify_keys
  end
end
