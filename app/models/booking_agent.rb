class BookingAgent < ApplicationRecord
  has_many :bookings, inverse_of: :booking_agent, dependent: :nullify

  validates :name, :code, :email, presence: true
  validates :email, format: Devise.email_regexp

  def to_s
    name
  end
end
