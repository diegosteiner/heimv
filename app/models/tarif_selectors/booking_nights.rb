# == Schema Information
#
# Table name: tarif_selectors
#
#  id         :bigint           not null, primary key
#  home_id    :bigint
#  type       :string
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module TarifSelectors
  class BookingNights < NumericDistinction
    def presumable_usage(usage)
      usage.booking.occupancy.nights
    end
  end
end
