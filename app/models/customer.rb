class Customer < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :first_name, :last_name, presence: true

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    "##{id} #{name}"
  end
end
