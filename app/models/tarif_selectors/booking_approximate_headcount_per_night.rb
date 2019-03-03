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
  class BookingApproximateHeadcountPerNight < NumericDistinction
    def presumable_usage(usage)
      usage.booking.approximate_headcount
    end

    # def select_usage(usage, _distinction)
    #   usage.booking.nights + 1
    # end
  end
end
