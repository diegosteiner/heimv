# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_responsibilities
#
#  id              :bigint           not null, primary key
#  ordinal         :integer
#  remarks         :text
#  responsibility  :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  booking_id      :uuid
#  operator_id     :bigint           not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_operator_responsibilities_on_booking_id       (booking_id)
#  index_operator_responsibilities_on_operator_id      (operator_id)
#  index_operator_responsibilities_on_ordinal          (ordinal)
#  index_operator_responsibilities_on_organisation_id  (organisation_id)
#  index_operator_responsibilities_on_responsibility   (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (operator_id => operators.id)
#  fk_rails_...  (organisation_id => organisations.id)
#
class OperatorResponsibility < ApplicationRecord
  RESPONSIBILITIES = { administration: 0, home_handover: 1, home_return: 2, billing: 3 }.freeze
  include RankedModel

  belongs_to :organisation, inverse_of: :operator_responsibilities
  belongs_to :operator, inverse_of: :operator_responsibilities
  belongs_to :booking, inverse_of: :operator_responsibilities, optional: true, touch: true

  has_many :assigning_conditions, -> { qualifiable_group(:assigning) }, as: :qualifiable, dependent: :destroy,
                                                                        class_name: :BookingCondition, inverse_of: false

  enum responsibility: RESPONSIBILITIES

  scope :ordered, -> { rank(:ordinal) }

  delegate :email, :locale, :contact_info, to: :operator

  validates :responsibility, presence: true
  validates :responsibility, uniqueness: { scope: :booking_id }, if: :booking_id
  ranks :ordinal, with_same: :organisation_id

  before_validation :update_booking_conditions

  accepts_nested_attributes_for :assigning_conditions, allow_destroy: true,
                                                       reject_if: :reject_booking_conditition_attributes?

  def reject_booking_conditition_attributes?(attributes)
    attributes[:type].blank?
  end

  def update_booking_conditions
    assigning_conditions.each { |condition| condition.assign_attributes(qualifiable: self, group: :assigning) }
  end

  def assign_to_booking?(booking)
    assigning_conditions.any? && BookingCondition.fullfills_all?(booking, assigning_conditions)
  end

  def self.assign(booking, *responsibilities)
    responsibilities.map do |responsibility|
      existing_operator = where(booking:, responsibility:).first
      next existing_operator if existing_operator.present?

      matching(booking, responsibility).first&.dup&.tap do |operator_responsibility|
        operator_responsibility.update(booking:)
      end
    end
  end

  def self.matching(booking, responsibility)
    booking.organisation.operator_responsibilities.ordered
           .where(responsibility:, booking: nil)
           .filter { |operator_responsibility| operator_responsibility.assign_to_booking?(booking) }
  end
end
