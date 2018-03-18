class BookingAgent < ApplicationRecord
  validates :name, :code, :email, presence: true
  validates :email, format: Devise.email_regexp

  def to_s
    name
  end
end
