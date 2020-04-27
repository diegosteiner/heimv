# == Schema Information
#
# Table name: tenants
#
#  id                   :bigint           not null, primary key
#  birth_date           :date
#  city                 :string
#  country              :string
#  email                :string           not null
#  email_verified       :boolean          default(FALSE)
#  first_name           :string
#  import_data          :jsonb
#  last_name            :string
#  phone                :text
#  remarks              :text
#  reservations_allowed :boolean
#  search_cache         :text             not null
#  street_address       :string
#  zipcode              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_id      :bigint           not null
#
# Indexes
#
#  index_tenants_on_email            (email)
#  index_tenants_on_organisation_id  (organisation_id)
#  index_tenants_on_search_cache     (search_cache)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class Tenant < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error
  belongs_to :organisation

  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, on: :public_update
  validates :birth_date, presence: true, on: :public_update
  validates :phone, presence: true, length: { minimum: 10 }, on: :public_update

  scope :ordered, -> { order(last_name: :ASC) }

  before_save do
    self.search_cache = contact_lines.flatten.join('\n')
  end

  def name
    "#{first_name} #{last_name}"
  end

  def salutation_name
    I18n.t('tenant.salutation', name: first_name)
  end

  def address_lines
    [
      name,
      street_address&.lines&.map(&:strip),
      "#{zipcode} #{city} #{country}"
    ].flatten.reject(&:blank?)
  end

  def address
    address_lines.join("\n")
  end

  def contact_lines
    address_lines + [phone, email].reject(&:blank?)
  end

  def email_validated!
    update(email_validated: true)
  end

  def to_s
    "##{id} #{name}"
  end

  def complete?
    [email, first_name, last_name, street_address, zipcode, city, country, birth_date, phone].all?(&:present?)
  end

  def to_liquid
    Public::TenantSerializer.new(self).serializable_hash.deep_stringify_keys
  end
end
