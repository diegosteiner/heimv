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
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  home_id            :bigint
#  organisation_id    :bigint
#
# Indexes
#
#  index_agent_bookings_on_booking_id       (booking_id)
#  index_agent_bookings_on_home_id          (home_id)
#  index_agent_bookings_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class AgentBooking < ApplicationRecord
  belongs_to :booking_agent, inverse_of: :agent_bookings, foreign_key: :booking_agent_code, primary_key: :code
  belongs_to :booking, inverse_of: :agent_booking
  has_one :occupancy, through: :booking
  belongs_to :organisation
  belongs_to :home

  validates :tenant_email, presence: true, if: :committed_request?
  validates :booking_agent_code, :booking, presence: true

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank, update_only: true

  def save_and_update_booking
    return unless valid?

    booking || build_booking
    booking.assign_attributes(email: tenant_email, committed_request: committed_request, agent_booking: self)

    return errors.add(:booking, :invalid) unless booking.valid?

    booking.save && save
  end

  def build_booking
    self.booking = super(home: home, committed_request: false, organisation: organisation, messages_enabled: true)
  end

  def build_occupancy(attributes = {})
    build_booking
    booking.build_occupancy(attributes)
  end

  def occupancy
    booking&.occupancy || build_occupancy
  end

  def booking_agent_responsible?
    !committed_request || !valid?
  end
end
