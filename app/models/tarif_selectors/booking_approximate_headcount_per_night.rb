# == Schema Information
#
# Table name: tarif_selectors
#
#  id         :bigint           not null, primary key
#  position   :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  home_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_home_id  (home_id)
#  index_tarif_selectors_on_type     (type)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
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
