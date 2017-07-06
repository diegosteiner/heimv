class Person < ApplicationRecord
  has_many :bookings

  validates :firstname, :lastname, presence: true

  def name
    "#{firstname} #{lastname}"
  end

  def to_s
    name
  end
end
