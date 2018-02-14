class Customer < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error
  attr_accessor :initial

  validates :email, presence: true
  validates :email, format: { with: Devise.email_regexp }
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, unless: :initial

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    "##{id} #{name}"
  end
end
