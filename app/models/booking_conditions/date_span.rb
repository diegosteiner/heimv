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
  class DateSpan < ::BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_operator '=': ->(actual_value:) { date_span_checker&.overlap?(actual_value) },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    compare_attribute begins_at: ->(booking:) { booking.begins_at },
                      ends_at: ->(booking:) { booking.ends_at },
                      span: ->(booking:) { booking.span },
                      now: ->(_booking:) { Time.zone.today }

    validates :compare_attribute, :compare_operator, presence: true

    def compare_value_regex
      DateSpanChecker::REGEX
    end

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute || :span, with: { booking: })
      evaluate_operator(compare_operator || :'=', with: { actual_value: })
    end

    protected

    def date_span_checker
      @date_span_checker ||= DateSpanChecker.parse(compare_value)
    end
  end
end
