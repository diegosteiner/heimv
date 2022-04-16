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
# Indexes
#
#  index_booking_agents_on_code_and_organisation_id  (code,organisation_id) UNIQUE
#  index_booking_agents_on_organisation_id           (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class BookingAgent < ApplicationRecord
  has_many :bookings, through: :agent_bookings
  has_many :agent_bookings, inverse_of: :booking_agent,
                            dependent: :nullify
  belongs_to :organisation, inverse_of: :booking_agents

  validates :name, :code, :email, presence: true
  validates :email, format: Devise.email_regexp
  validates :code, uniqueness: { scope: %i[organisation_id] }

  def to_s
    name
  end

  def locale
    (organisation & locale) || I18n.locale
  end
end
