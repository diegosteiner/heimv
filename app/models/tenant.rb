# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id                              :bigint           not null, primary key
#  address_addon                   :string
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
#  locale                          :string           default("de"), not null
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

  locale_enum default: I18n.locale

  validates :email, allow_blank: true, format: { with: Devise.email_regexp }, uniqueness: { scope: :organisation_id }
  validates :email, presence: true, on: :public_update
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, on: :public_update
  validates :street_address, length: { maximum: 255 }
  validates :phone, presence: true, length: { minimum: 10, maximum: 255 }, on: :public_update
  validates :locale, presence: true
  validates :birth_date, presence: true, on: :public_update, if: :birth_date_required?

  scope :ordered, -> { order(last_name: :ASC, first_name: :ASC, id: :ASC) }

  before_validation do
    self.email = email&.strip.presence
  end

  before_save do
    self.search_cache = contact_lines.flatten.join('\n')
  end

  def full_name
    [first_name, last_name].compact_blank.join(' ')
  end

  def name
    full_name
  end

  def names
    @names ||= {
      first_name: first_name.presence,
      last_name: last_name.presence,
      full_name:,
      nickname: nickname.presence,
      friendly_name: [nickname, first_name].compact_blank.first
    }
  end

  def salutation_name
    I18n.t('tenant.salutation', **names)
  end

  def address_lines
    [
      address_addon&.strip,
      street_address&.lines&.map(&:strip),
      "#{zipcode} #{city} #{country_code}"
    ].flatten.compact_blank
  end

  def full_address_lines
    [full_name, address_lines].flatten
  end

  def address
    full_address_lines.join("\n")
  end

  def contact_lines
    full_address_lines + [phone&.lines, email].flatten.compact_blank
  end

  def contact_info
    [phone&.lines, email].flatten.compact_blank.join(', ')
  end

  def to_s
    "##{id} #{names[:full_name]}"
  end

  def complete?
    valid? &&
      [email, first_name, last_name, street_address, zipcode, city, country_code, phone].all?(&:present?) &&
      (!birth_date_required? || birth_date.present?)
  end

  def changed_values
    changes.transform_values(&:last)
  end

  def birth_date_required?
    organisation&.settings&.tenant_birth_date_required
  end
end
