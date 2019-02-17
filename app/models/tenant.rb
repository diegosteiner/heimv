class Tenant < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :email, presence: true
  validates :email, format: { with: Devise.email_regexp }
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, on: :public_update
  validates :birth_date, :phone, presence: true, on: :public_update

  before_save do
    self.search_cache = (address_lines + [email, phone]).flatten.join('\n')
  end

  def name
    "#{first_name} #{last_name}"
  end

  def salutation_name
    "Hallo #{first_name}"
  end

  def address_lines
    [name, street_address, "#{zipcode} #{city}"].reject(&:blank?)
  end

  def contact_lines
    address_lines + [phone, email].reject(&:blank?)
  end

  def to_s
    "##{id} #{name}"
  end

  def to_liquid
    Public::TenantSerializer.new(self).serializable_hash.deep_stringify_keys
  end
end
