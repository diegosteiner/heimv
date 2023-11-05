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

    enum trigger: { manager: 0, tenant: 1, auto: 2 }, _prefix: true

    def self.log(booking, trigger:, action: nil, user: nil, data: {})
      data = data.reverse_merge({
                                  booking: booking.previous_changes,
                                  tenant: booking.tenant&.previous_changes, action:,
                                  transitions: booking.previous_transitions
                                }).compact_blank

      return if data.values.none?

      create!(booking:, trigger:, user:, data:)
    end

    def logged_transitions
      data&.fetch('transitions', nil)
    end

    def logged_action
      BookingActions.const_get(data.fetch('action', nil)) if data.is_a?(Hash) && data['action'].present?
    rescue NameError
      nil
    end

    def logged_changes
      changes = data&.slice('booking', 'tenant')&.filter { |_key, value| value.present? } || []
      changes.transform_keys { |key| LOGGED_CHANGES_MAP[key] }
    end
  end
end
