# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_operators
#
#  id             :bigint           not null, primary key
#  remark         :text
#  responsibility :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid             not null
#  operator_id    :bigint           not null
#
# Indexes
#
#  index_booking_operators_on_booking_id      (booking_id)
#  index_booking_operators_on_operator_id     (operator_id)
#  index_booking_operators_on_responsibility  (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (operator_id => operators.id)
#
class BookingOperator < ApplicationRecord
  belongs_to :booking, inverse_of: :booking_operators
  belongs_to :operator, inverse_of: :booking_operators

  enum responsibility: { administration: 0, home_handover: 1, home_return: 2, billing: 3 }, _suffix: true

  validates :responsibility, presence: true
end
