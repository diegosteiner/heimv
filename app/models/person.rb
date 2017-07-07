class Person < ApplicationRecord
  has_many :bookings

  validates :first_name, :last_name, presence: true

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    name
  end
end
