# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_state_transitions
#
#  id           :bigint           not null, primary key
#  booking_data :json
#  metadata     :json
#  most_recent  :boolean          not null
#  sort_key     :integer          not null
#  to_state     :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#
# Indexes
#
#  index_booking_state_transitions_on_booking_id  (booking_id)
#  index_booking_transitions_parent_most_recent   (booking_id,most_recent) UNIQUE WHERE most_recent
#  index_booking_transitions_parent_sort          (booking_id,sort_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

class Booking
  class StateTransition < ApplicationRecord
    include Translatable
    # include Statesman::Adapters::ActiveRecordTransition does not support JSON column
    class_attribute :updated_timestamp_column
    self.updated_timestamp_column = :updated_at

    belongs_to :booking, inverse_of: :state_transitions

    scope :ordered, -> { order(sort_key: :ASC) }

    before_save :serialize_booking
    after_destroy :update_most_recent, if: :most_recent?

    def self.initial_for(booking, state)
      last_transition = booking.state_transitions.ordered.last
      last_transition&.update(most_recent: false)
      sort_key = (last_transition&.sort_key || 0) + 1
      create(booking:, to_state: state, sort_key:, most_recent: true)
    end

    private

    def serialize_booking
      self.booking_data = booking.attributes
    end

    def update_most_recent
      last_transition = booking.state_transitions.ordered.last
      return if last_transition.blank?

      # rubocop:disable Rails/SkipsModelValidations
      last_transition.update_column(:most_recent, true)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
