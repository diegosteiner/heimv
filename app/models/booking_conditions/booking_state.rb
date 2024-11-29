# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id                :bigint           not null, primary key
#  compare_attribute :string
#  compare_operator  :string
#  compare_value     :string
#  group             :string
#  must_condition    :boolean          default(TRUE)
#  qualifiable_type  :string
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organisation_id   :bigint
#  qualifiable_id    :bigint
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

    attribute :compare_operator, default: -> { :'=' }

    compare_operator '=': ->(booking:, compare_value:) { booking.booking_flow.current_state&.to_s == compare_value },
                     '>': ->(booking:, compare_value:) { booking_state_transitions_include?(booking, compare_value) },
                     '<': ->(booking:, compare_value:) { !booking_state_transitions_include?(booking, compare_value) },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_value, :compare_operator, presence: true

    def compare_values
      organisation.booking_flow_class.state_classes.transform_values(&:translate).to_a
    end

    def evaluate!(booking)
      evaluate_operator(compare_operator, with: { booking:, compare_value: })
    end

    protected

    def booking_state_transitions_include?(booking, state)
      booking.state_transitions.pluck(:to_state).include?(state&.to_s)
    end
  end
end
