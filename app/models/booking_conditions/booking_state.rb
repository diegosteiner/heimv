# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id               :bigint           not null, primary key
#  distinction      :string
#  group            :string
#  must_condition   :boolean          default(TRUE)
#  qualifiable_type :string
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint
#  qualifiable_id   :bigint
#
# Indexes
#
#  index_booking_conditions_on_organisation_id                      (organisation_id)
#  index_booking_conditions_on_qualifiable                          (qualifiable_id,qualifiable_type,group)
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module BookingConditions
  class BookingState < BookingCondition
    BookingCondition.register_subtype self

    def evaluate(booking)
      booking.booking_flow.current_state&.to_s == distinction
    end
  end
end
