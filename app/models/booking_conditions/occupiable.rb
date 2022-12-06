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
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (qualifiable_id => tarifs.id)
#

module BookingConditions
  class Occupiable < BookingCondition
    BookingCondition.register_subtype self

    validate do
      next if distinction_scope.exists?(id: distinction)

      errors.add(:distinction, :invalid)
    end

    def evaluate(booking)
      distinction == booking.occupancy&.home&.id&.to_s
    end

    def distinction_scope
      organisation.homes
    end
  end
end
