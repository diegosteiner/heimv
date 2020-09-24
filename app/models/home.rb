# frozen_string_literal: true

# == Schema Information
#
# Table name: homes
#
#  id               :bigint           not null, primary key
#  address          :text
#  booking_margin   :integer          default(0)
#  janitor          :text
#  min_occupation   :integer
#  name             :string
#  ref              :string
#  requests_allowed :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_homes_on_organisation_id  (organisation_id)
#  index_homes_on_ref              (ref) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class Home < ApplicationRecord
  validates :name, :ref, presence: true
  has_one_attached :house_rules
  has_many :occupancies, dependent: :destroy
  has_many :bookings, dependent: :restrict_with_error
  has_many :tarifs, ->(home) { Tarif.unscoped.where(home: home, booking: nil) },
           dependent: :destroy, inverse_of: :home
  has_many :meter_reading_periods, -> { ordered }, through: :tarifs, inverse_of: :home, dependent: :destroy
  belongs_to :organisation, inverse_of: :homes

  accepts_nested_attributes_for :tarifs, reject_if: :all_blank, update_only: true

  def to_s
    name
  end

  def to_liquid
    Manage::HomeSerializer.render_as_hash(self).deep_stringify_keys
  end
end
