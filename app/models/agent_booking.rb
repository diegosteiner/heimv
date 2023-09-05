# frozen_string_literal: true

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
#  tenant_email       :string
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_agent_id   :bigint           not null
#  booking_id         :uuid
#  organisation_id    :bigint
#
# Indexes
#
#  index_agent_bookings_on_booking_agent_id  (booking_agent_id)
#  index_agent_bookings_on_booking_id        (booking_id)
#  index_agent_bookings_on_organisation_id   (organisation_id)
#  index_agent_bookings_on_token             (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_agent_id => booking_agents.id)
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class AgentBooking < ApplicationRecord
  belongs_to :booking_agent, inverse_of: :agent_bookings
  belongs_to :booking, inverse_of: :agent_booking, autosave: true, touch: true
  belongs_to :organisation

  has_secure_token :token, length: 48

  accepts_nested_attributes_for :booking, reject_if: :all_blank, update_only: true

  before_validation :update_booking

  validates :tenant_email, format: Devise.email_regexp, presence: true, if: :committed_request
  validates :booking_agent_code, presence: true
  validate do
    errors.add(:booking_agent_code, :invalid) if booking_agent.blank?
    errors.add(:tenant_email, :invalid) if tenant_email.present? && tenant_email == booking_agent&.email
  end

  def tenant_email=(value)
    super
    booking.email = value
  end

  def tenant_email
    super || booking.email
  end

  def update_booking
    booking.organisation ||= organisation
  end

  def booking
    super || self.booking = build_booking(committed_request: false, notifications_enabled: true,
                                          email: tenant_email.presence)
  end

  def booking_agent_responsible?
    !committed_request || !valid?
  end

  def booking_agent
    super || self.booking_agent = organisation.booking_agents.find_by(code: booking_agent_code)
  end
end
