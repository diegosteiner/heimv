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

  # def email
  #   booking.email
  # end

  # def editable
  #   booking.editable
  # end

  # def committed_request?
  #   booking.committed_request?
  # end
end
