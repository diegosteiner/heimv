# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_logs
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  trigger    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :uuid             not null
#  user_id    :bigint
#
# Indexes
#
#  index_booking_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Booking
  class Log < ApplicationRecord
    LOGGED_CHANGES_MAP = { 'booking' => Booking, 'tenant' => Tenant }.freeze
    belongs_to :booking, inverse_of: :logs
    belongs_to :user, inverse_of: :booking_logs, optional: true

    enum :trigger, { manager: 0, tenant: 1, auto: 2, booking_agent: 3 }, prefix: true

    def self.log(booking, trigger:, action: nil, user: nil, data: {})
      data = data.reverse_merge(
        booking: booking.previous_changes,
        tenant: booking.tenant&.previous_changes,
        action: action.is_a?(BookingActions::Base) ? action.class.name : action,
        transitions: booking.applied_transitions
      ).compact_blank

      create!(booking:, trigger:, user:, data:) if data.values.any?
    end

    def logged_transitions
      data&.fetch('transitions', nil)
    end

    def logged_action
      action_class = data.try('[]', 'action')
      BookingActions.const_get(action_class) if action_class.is_a?(String)
    rescue NameError
      action_class
    end

    def logged_changes
      changes = data&.slice('booking', 'tenant')&.filter { |_key, value| value.present? } || []
      changes.transform_keys { |key| LOGGED_CHANGES_MAP[key] }
    end
  end
end
