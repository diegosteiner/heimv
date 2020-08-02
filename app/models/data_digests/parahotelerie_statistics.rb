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
  class ParahotelerieStatistics < DataDigests::Tarif
    class Period < DataDigests::Tarif::Period
      def data_header
        [
          ::Occupancy.human_attribute_name(:begins_at), ::Occupancy.human_attribute_name(:ends_at),
          I18n.t('data_digests/parahotelerie_statistics.total_overnight_stays'),
          ::Tenant.human_attribute_name(:country)
        ]
      end

      def headcount(booking)
        booking.usages.where(tarif_id: ::Tarif.find_with_booking_copies(@data_digest.tarif_ids)).sum(:used_units)
      end

      def data_row(booking)
        [I18n.l(booking.occupancy.begins_at, format: :short), I18n.l(booking.occupancy.ends_at, format: :short),
         headcount(booking), booking.tenant&.country]
      end
    end
  end
end
