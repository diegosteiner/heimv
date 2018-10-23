class Message < ApplicationRecord
  belongs_to :booking, inverse_of: :messages
  has_one :tenant, through: :booking

  def recipient_addresses
    [booking.email]
  end

  def deliver
  end

end
