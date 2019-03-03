# == Schema Information
#
# Table name: tarif_selectors
#
#  id         :bigint(8)        not null, primary key
#  home_id    :bigint(8)
#  type       :string
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module TarifSelectors
  class BookingOvernightStays < NumericDistinction
    def presumable_usage(usage)
      usage.booking.overnight_stays
    end
  end
end
