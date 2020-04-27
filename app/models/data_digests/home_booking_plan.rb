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
    def filter
      @filter ||= ::Booking::Filter.new(filter_params)
    end

    def column_widths
      [82, 100, 100, 50, 70, 180, 148]
    end

    protected

    def generate_tabular_header
      [
        ::Booking.human_attribute_name(:ref), ::Booking.human_attribute_name(:purpose),
        ::Occupancy.human_attribute_name(:begins_at), ::Occupancy.human_attribute_name(:ends_at),
        ::Occupancy.human_attribute_name(:nights),
        ::Tenant.model_name.human, ::Tenant.human_attribute_name(:phone)
      ]
    end

    def generate_tabular_footer
      []
    end

    def generate_tabular_row(booking)
      [booking.ref, ::Booking.human_enum(:purpose, booking.purpose)] +
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
