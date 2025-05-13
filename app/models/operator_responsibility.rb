# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_responsibilities
#
#  id                   :bigint           not null, primary key
#  assigning_conditions :jsonb
#  ordinal              :integer
#  remarks              :text
#  responsibility       :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  operator_id          :bigint           not null
#  organisation_id      :bigint           not null
#

class OperatorResponsibility < ApplicationRecord
  RESPONSIBILITIES = { administration: 0, home_handover: 1, home_return: 2, billing: 3 }.freeze

  include RankedModel
  include StoreModel::NestedAttributes

  belongs_to :organisation, inverse_of: :operator_responsibilities
  belongs_to :operator, inverse_of: :operator_responsibilities
  belongs_to :booking, inverse_of: :operator_responsibilities, optional: true, touch: true

  enum :responsibility, RESPONSIBILITIES

  attribute :assigning_conditions, BookingCondition.one_of.to_array_type, nil: true

  scope :ordered, -> { rank(:ordinal) }

  delegate :email, :locale, :contact_info, to: :operator

  validates :responsibility, presence: true
  validates :responsibility, uniqueness: { scope: :booking_id }, if: :booking_id
  validates :assigning_conditions, store_model: true, allow_nil: true

  ranks :ordinal, with_same: :organisation_id

  accepts_nested_attributes_for :assigning_conditions, allow_destroy: true
  before_validation :set_organisation

  def set_organisation
    self.organisation ||= booking&.organisation
  end

  def assign_to_booking?(booking)
    assigning_conditions.blank? || assigning_conditions.all? { it.fullfills?(booking) }
  end

  def to_s
    "#{OperatorResponsibility.human_enum(:responsibility, responsibility)}: #{operator}"
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
