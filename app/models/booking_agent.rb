# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_agents
#
#  id                       :bigint           not null, primary key
#  address                  :text
#  code                     :string
#  email                    :string
#  name                     :string
#  provision                :decimal(, )
#  request_deadline_minutes :integer          default(14400)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  organisation_id          :bigint           not null
#

class BookingAgent < ApplicationRecord
  has_many :bookings, through: :agent_bookings
  has_many :agent_bookings, inverse_of: :booking_agent,
                            dependent: :nullify
  belongs_to :organisation, inverse_of: :booking_agents

  normalizes :email, with: ->(email) { email.present? ? EmailAddress.normal(email) : nil }

  validates :name, :code, :email, presence: true
  validates :code, uniqueness: { scope: %i[organisation_id] }
  validate do
    errors.add(:email, :invalid) unless email.nil? || EmailAddress.valid?(email, host_validation: :syntax, dns_validation: false)
  end

  def to_s
    name
  end

  def locale
    organisation&.locale || I18n.locale
  end
end
