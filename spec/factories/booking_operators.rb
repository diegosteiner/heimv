# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_operators
#
#  id             :bigint           not null, primary key
#  index          :integer
#  remarks        :text
#  responsibility :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid             not null
#  operator_id    :bigint           not null
#
# Indexes
#
#  index_booking_operators_on_booking_id      (booking_id)
#  index_booking_operators_on_index           (index)
#  index_booking_operators_on_operator_id     (operator_id)
#  index_booking_operators_on_responsibility  (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (operator_id => operators.id)
#
FactoryBot.define do
  factory :booking_operator do
    booking { nil }
    operator { nil }
    responsipility { '' }
    remark { 'MyText' }
  end
end
