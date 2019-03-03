# == Schema Information
#
# Table name: booking_agents
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  code       :string
#  email      :string
#  address    :text
#  provision  :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BookingAgent < ApplicationRecord
  has_many :bookings, inverse_of: :booking_agent, dependent: :nullify

  validates :name, :code, :email, presence: true
  validates :email, format: Devise.email_regexp

  def to_s
    name
  end
end
