# == Schema Information
#
# Table name: booking_transitions
#
#  id           :bigint(8)        not null, primary key
#  to_state     :string           not null
#  sort_key     :integer          not null
#  booking_id   :uuid             not null
#  most_recent  :boolean          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  metadata     :json
#  booking_data :json
#

class BookingTransition < ApplicationRecord
  # include Statesman::Adapters::ActiveRecordTransition
  class_attribute :updated_timestamp_column
  self.updated_timestamp_column = :updated_at

  belongs_to :booking, inverse_of: :booking_transitions, touch: true

  after_destroy :update_most_recent, if: :most_recent?
  before_save :serialize_booking
  after_save :update_booking_state

  private

  def serialize_booking
    self.booking_data = booking.attributes
  end

  def update_booking_state
    # rubocop:disable Rails/SkipsModelValidations
    booking.update_columns(state: to_state)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def update_most_recent
    last_transition = booking.booking_transitions.order(:sort_key).last
    return if last_transition.blank?

    last_transition.update(most_recent: true)
  end
end
