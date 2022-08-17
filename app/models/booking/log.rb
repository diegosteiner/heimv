# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_logs
#
#  id         :bigint           not null, primary key
#  data       :jsonb
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
    belongs_to :booking, inverse_of: :logs
    belongs_to :user, inverse_of: :booking_logs, optional: true

    # def self.log_update(booking, **attributes)
    #   return unless booking.previous_changes.any? ||
    #                 booking.tenant.previous_changes.any? ||
    #                 booking.occupancy.previous_changes.any? ||
    #                 booking.previous_transitions.present?

    #   booking.logs.create(attributes.merge(kind: :update, data: { booking: booking.previous_changes,
    #                                                               tenant: booking.tenant.previous_changes,
    #                                                               occupancy: booking.occupancy.previous_changes,
    #                                                               transitions: booking.previous_transitions }))
    # end

    # def self.log_action(booking, action, **attributes)
    #   return if action.blank?

    #   booking.logs.create(attributes.merge(kind: :action, data: { action: action,
    #                                                               transitions: booking.previous_transitions }))
    # end

    def self.log(booking, action: nil, user: nil, data: {})
      data = data.reverse_merge({
                                  booking: booking.previous_changes, occupancy: booking.occupancy.previous_changes,
                                  tenant: booking.tenant.previous_changes, action: action,
                                  transitions: booking.previous_transitions
                                }).compact_blank

      return if data.values.none?

      create!(booking: booking, user: user, data: data)
    end
  end
end
