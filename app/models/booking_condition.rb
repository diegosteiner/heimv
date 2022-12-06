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

class BookingCondition < ApplicationRecord
  include Subtypeable

  belongs_to :qualifiable, polymorphic: true, optional: true
  belongs_to :organisation

  before_validation :set_organisation

  def self.distinction_regex
    //
  end

  def self.binary_comparison(value, other_value, operator: '==')
    {
      '<' => -> { value < other_value },
      '<=' => -> { value <= other_value },
      '>' => -> { value > other_value },
      '>=' => -> { value >= other_value }
    }.fetch(operator, -> { value == other_value }).call
  end

  def self.fullfills_all?(booking, booking_conditions)
    booking_conditions.map do |condition|
      condition.evaluate(booking) || (condition.must_condition ? false : nil)
    end.compact.all?
  end

  def distinction_match
    @distinction_match ||= self.class.distinction_regex.match(distinction)
  end

  validates :distinction, format: { with: distinction_regex }, allow_blank: true
  validates :type, presence: true

  def to_s
    "#{model_name.human}: #{distinction}"
  end

  def set_organisation
    self.organisation ||= qualifiable.try(:organisation)
  end

  def evaluate(booking)
    booking.present?
  end
end
