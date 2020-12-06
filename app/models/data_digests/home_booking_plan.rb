# frozen_string_literal: true

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
  class HomeBookingPlan < DataDigests::Booking
    class Period < DataDigests::Booking::Period
      def data_header
        [
          ::Booking.human_attribute_name(:ref), ::Booking.human_attribute_name(:purpose),
          ::Occupancy.human_attribute_name(:begins_at), ::Occupancy.human_attribute_name(:ends_at),
          ::Occupancy.human_attribute_name(:nights),
          ::Tenant.model_name.human, ::Tenant.human_attribute_name(:phone)
        ]
      end

      def data_row(booking)
        [booking.ref, booking.purpose] +
          occupancy_cells(booking.occupancy) + tenant_cells(booking)
      end

      def occupancy_cells(occupancy)
        [I18n.l(occupancy.begins_at, format: :short), I18n.l(occupancy.ends_at, format: :short),
         occupancy.nights]
      end

      def tenant_cells(booking)
        [[booking.tenant_organisation, booking.tenant&.name].join("\n"), booking.tenant&.phone]
      end
    end
  end
end
