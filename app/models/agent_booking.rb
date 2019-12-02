# == Schema Information
#
# Table name: agent_bookings
#
#  id                 :uuid             not null, primary key
#  accepted_request   :boolean
#  booking_agent_code :string
#  booking_agent_ref  :string
#  committed_request  :boolean
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#
# Indexes
#
#  index_agent_bookings_on_booking_id  (booking_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

class AgentBooking < ApplicationRecord
  belongs_to :booking_agent, inverse_of: :agent_bookings, foreign_key: :booking_agent_code, primary_key: :code
  belongs_to :booking, inverse_of: :agent_booking

  accepts_nested_attributes_for :booking, reject_if: :all_blank, update_only: true
  attribute :email

  delegate :email, :email=, :committed_request, :committed_request?, :editable, to: :booking, allow_nil: true

  validates :email, presence: true, if: :committed_request?

  def booking_agent_responsible?
    !committed_request
  end
end
