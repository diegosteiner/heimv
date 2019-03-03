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
  def booking_strategy
    BookingStrategies::Default
  end
end
