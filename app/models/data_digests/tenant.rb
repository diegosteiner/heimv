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
#  organisation_id    :bigint           default(1), not null
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
  class Tenant < DataDigests::Booking
    def tarif_ids=(tarif_ids)
      data_digest_params['tarif_ids'] = tarif_ids.reject(&:blank?)
    end

    def tarif_ids
      data_digest_params.fetch('tarif_ids', [])
    end

    def tarifs
      ::Tarif.where(id: tarif_ids)
    end

    def column_widths
      [70, 80, 100, 100, 60, 140, 140, 50]
    end

    protected

    def generate_tabular_header
      super + [
        ::Tenant.model_name.human, '', ::Occupancy.human_attribute_name(:nights)
      ]
    end

    def generate_tabular_row(booking)
      super + booking.instance_eval do
        [
          tenant&.address_lines&.join("\n"), [tenant&.email, tenant&.phone].join("\n"), occupancy&.nights
        ]
      end
    end
  end
end
