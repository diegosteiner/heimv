# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  data_digest_params :jsonb
#  filter_params      :jsonb
#  label              :string
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_data_digests_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigests
  class ParahotelerieStatistics < DataDigests::Booking
    def filter
      @filter ||= ::Booking::Filter.new(filter_params)
    end

    protected

    def generate_tabular_header
      [
        ::Occupancy.human_attribute_name(:begins_at), ::Occupancy.human_attribute_name(:ends_at),
        ::Booking.human_attribute_name(:approximate_headcount), ::Tenant.human_attribute_name(:country)
      ]
    end

    def generate_tabular_footer
      []
    end

    def generate_tabular_row(booking)
      [I18n.l(booking.occupancy.begins_at, format: :short), I18n.l(booking.occupancy.ends_at, format: :short),
       booking.approximate_headcount, booking.tenant&.country]
    end
  end
end
