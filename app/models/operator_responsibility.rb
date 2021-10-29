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
#  home_id         :bigint
#  operator_id     :bigint           not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_operator_responsibilities_on_booking_id       (booking_id)
#  index_operator_responsibilities_on_home_id          (home_id)
#  index_operator_responsibilities_on_operator_id      (operator_id)
#  index_operator_responsibilities_on_ordinal          (ordinal)
#  index_operator_responsibilities_on_organisation_id  (organisation_id)
#  index_operator_responsibilities_on_responsibility   (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (operator_id => operators.id)
#  fk_rails_...  (organisation_id => organisations.id)
#
class OperatorResponsibility < ApplicationRecord
  include RankedModel

  belongs_to :organisation, inverse_of: :operator_responsibilities
  belongs_to :home, inverse_of: :operator_responsibilities
  belongs_to :operator, inverse_of: :operator_responsibilities
  belongs_to :booking, inverse_of: :operator_responsibilities, optional: true

  enum responsibility: { administration: 0, home_handover: 1, home_return: 2, billing: 3 }.freeze, _suffix: true

  scope :ordered, -> { rank(:ordinal) }

  validates :operator_id, presence: true
  validates :responsibility, presence: true
  validates :responsibility, uniqueness: { scope: :booking_id }, if: :booking_id
  ranks :ordinal, with_same: :organisation_id

  def self.assign_to_booking(booking, responsibility)
    booking.organisation.operator_responsibilities.ordered
           .where(responsibility: responsibility, home: [booking.home,
                                                         nil]).first&.dup&.tap do |operator_responsibility|
      operator_responsibility.update(booking: booking, home: booking.home)
    end
  end
end
