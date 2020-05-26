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
  class Tarif < DataDigests::Booking
    def tarif_ids=(tarif_ids)
      data_digest_params['tarif_ids'] = tarif_ids.reject(&:blank?)
    end

    def tarif_ids
      data_digest_params.fetch('tarif_ids', [])
    end

    def tarifs
      ::Tarif.where(id: tarif_ids)
    end

    class Period < DataDigests::Booking::Period
      include ActionView::Helpers::NumberHelper

      def data_header
        super + @data_digest.tarifs.flat_map do |tarif|
          [
            "#{tarif.label} (#{::Usage.human_attribute_name(:used_units)})",
            "#{tarif.label} (#{::Usage.human_attribute_name(:price)})"
          ]
        end
      end

      def data_row(booking)
        super + @data_digest.tarifs.flat_map do |tarif|
          usage = booking.usages.of_tarif(tarif).take
          next ['', ''] unless usage

          [

            ActiveSupport::NumberHelper.number_to_rounded(usage.used_units || 0,
                                                          precision: 2, strip_insignificant_zeros: true),
            number_to_currency(usage.price || 0, unit: '')
          ]
        end
      end
    end
  end
end
