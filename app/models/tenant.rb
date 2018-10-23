class Tenant < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  attr_accessor :skip_exact_validation

  validates :email, presence: true
  validates :email, format: { with: Devise.email_regexp }
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, unless: :skip_exact_validation?

  before_save do
    self.search_cache = (address_lines + [email, phone]).join('\n')
  end

  def skip_exact_validation?
    skip_exact_validation && [first_name, last_name, street_address, zipcode, city].none?(&:present?)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def address_lines
    [name, street_address, "#{zipcode} #{city}"].reject(&:blank?)
  end

  def to_s
    "##{id} #{name}"
  end
end
