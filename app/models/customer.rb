class Customer < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :email, presence: true
  validates :email, format: { with: Devise.email_regexp }

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    "##{id} #{name}"
  end
end
