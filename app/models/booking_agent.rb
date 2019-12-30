# == Schema Information
#
# Table name: booking_agents
#
#  id              :bigint           not null, primary key
#  address         :text
#  code            :string
#  email           :string
#  name            :string
#  provision       :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           default(1), not null
#
# Indexes
#
#  index_booking_agents_on_code             (code)
#  index_booking_agents_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class BookingAgent < ApplicationRecord
  has_many :bookings, through: :agent_bookings
  has_many :agent_bookings, inverse_of: :booking_agent, dependent: :nullify
  belongs_to :organisation

  validates :name, :code, :email, presence: true
  validates :email, format: Devise.email_regexp

  def to_s
    name
  end
end
