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
#  tenant_infos       :text
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_agent_id   :bigint           not null
#  booking_id         :uuid
#  organisation_id    :bigint
#

class AgentBooking < ApplicationRecord
  belongs_to :booking_agent, inverse_of: :agent_bookings
  belongs_to :booking, inverse_of: :agent_booking, autosave: true, touch: true
  belongs_to :organisation

  has_secure_token :token, length: 48

  normalizes :tenant_email, with: ->(email) { email.present? ? EmailAddress.normal(email) : nil }

  accepts_nested_attributes_for :booking, reject_if: :all_blank, update_only: true

  before_validation :update_booking
  after_validation do
    %w[booking.email booking.tenant.email booking.home].each { |error| errors.delete(error) }
  end

  validates :tenant_email, presence: true, if: :committed_request
  validates :booking_agent_code, presence: true
  validate do
    errors.add(:booking_agent_code, :invalid) if booking_agent.blank?
    errors.add(:tenant_email, :invalid) if tenant_email.present? && tenant_email == booking_agent&.email
    errors.add(:tenant_email, :invalid) unless tenant_email.blank? || EmailAddress.valid?(tenant_email)
  end

  def tenant_email=(value)
    super
    booking.email ||= value
  end

  def tenant_email
    super.presence || booking.email
  end

  def committed_request
    booking&.committed_request
  end

  def update_booking
    booking.organisation ||= organisation
    booking.tenant || booking.build_tenant
    booking.tenant.organisation ||= organisation
    booking.email ||= tenant_email
  end

  def booking
    super || self.booking = build_booking(committed_request: false, notifications_enabled: true,
                                          organisation:, email: self[:tenant_email].presence)
  end

  def booking_agent_responsible?
    !committed_request || !valid?
  end

  def booking_agent
    super || self.booking_agent = organisation.booking_agents.find_by(code: booking_agent_code)
  end
end
