# == Schema Information
#
# Table name: organisations
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  ref        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organisation < ApplicationRecord
  has_many :homes, inverse_of: :organisation, dependent: :restrict_with_exception
  has_many :bookings, inverse_of: :organisation, dependent: :restrict_with_exception
  has_many :tenants, inverse_of: :organisation, dependent: :restrict_with_exception

  def booking_strategy
    BookingStrategies::Default
  end

  def self.default
    @default = Organisation.find_by(ref: ENV.fetch('DEFAULT_ORG'))
  end
end
